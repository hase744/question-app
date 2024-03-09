class User::RequestsController < User::Base
  layout "search_layout", only: :index
  before_action :check_login, only:[:new, :create, :edit, :destroy, :update, :preview, :edit, :publish ] #ログイン済みである
  before_action :check_stripe, only:[:new, :create, :destroy, :update, :preview, :publish] #Stripeのアカウントが有効である
  before_action :define_transaction, only:[:purchase, :publish, :preview , :update, :publish, :purchase]
  before_action :define_request, only:[:create, :edit, :destroy, :update, :preview, :publish, :purchase]
  before_action :define_service, only:[:new, :create, :edit, :destroy, :update, :preview, :publish, :purchase] #Stripeのアカウントが有効である
  before_action :check_service_buyable, only:[:new, :edit, :create, :update, :previous, :publish] #サービスが購入可能である
  before_action :check_service_updated, only:[:publish, :edit, :update] #サービスを購入ようとした後、サービス内容が更新されてないかどうか
  before_action :check_new_at, only:[:create]
  before_action :check_original_request, only:[:new, :create] #購入しようとしているサービスが自分の依頼に対する提案である
  before_action :check_previous_request, only:[:new, :create] #以前に購入しようとしたことがある
  before_action :check_budget_sufficient, only:[:new, :create, :publish, :purchase]
  def index
    users = User.where(is_published: true, is_suspended:false, is_deleted:false)
    @requests = Request
    @requests = @requests.left_joins(:request_categories, :user)
    @requests = solve_n_plus_1(@requests)
    @requests = @requests.where(is_published: true, is_inclusive:true, user:{is_published: true, is_suspended:false, is_deleted:false})
    @requests = @requests.where("title LIKE?", "%#{params[:word]}%")
    @requests = @requests.order(id: :DESC)
    #アカウントが非公開でないか
    #@requests = @requests.where(user:{is_published: true})

    if params[:categories].present?
      @requests = @requests.where(request_categories: {category_id: params[:categories].split(",").map(&:to_i)})
    end

    if params[:request_form].present?
      @requests = @requests.where(request_form_id: params[:request_form])
    end

    if params[:delivery_form].present?
      @requests = @requests.where(delivery_form_id: params[:delivery_form])
    end

    if params[:suggestion_deadline].present?
      @requests = @requests.where("suggestion_deadline > ?", DateTime.parse(params[:suggestion_deadline]))
      #検索された日時 < 期限
      #前 < 後
    end

    if params[:can_suggest] == "1"
      #現在の日時 < 依頼の期限
      #前 < 後
      @requests = @requests.where("suggestion_deadline > ?", DateTime.now)
    end
    
    if params[:max_price].present?
    @requests = @requests.where("max_price <= ?", "#{params[:max_price]}")
    end
    if params[:mini_price].present?
      @requests = @requests.where("? <= max_price", "#{params[:mini_price]}")
      end

    @requests = @requests.page(params[:page]).includes(:user).per(10)
    gon.layout = "action_index"
  end

  def show
    @request = Request.find(params[:id])
    @request.set_item_values
    if !@request.is_published
      flash.notice = "依頼が非公開です。"
      redirect_to user_requests_path
    elsif !@request.user.is_published
      flash.notice = "アカウントが非公開です。"
      redirect_to user_requests_path
    elsif @request.user.is_deleted
      flash.notice = "アカウントが存在しません。"
      redirect_to user_requests_path
    else
      if user_signed_in?
        @relationship = Relationship.find_by(followee: @request.user, follower_id: current_user.id)
      end
      
      if !@request.user.is_published
        flash.notice = "アカウントが非公開です。"
        redirect_to user_requests_path
      elsif @request.user.is_deleted
        flash.notice = "アカウントが存在しません。"
        redirect_to user_requests_path
      end

      @request.update(total_views:@request.total_views + 1)
    end
  end

  def new
    if params[:request]
      @request = Request.new(request_params)
      @request.set_item_values
    else
      @request = Request.new(service_id:params[:service_id], request_form_id:1)
    end
    set_new_values
  end

  def edit
    set_edit_values
    @request.set_item_values
  end

  def preview
    if @transaction
      @request.service = @transaction.service
    end
    @request.set_item_values
    set_preview_values
  end

  def update
    @transactions = Transaction.where(request:@request) #サービスの購入である
    if @transactions.present? #サービスの購入である
      @request.assign_attributes(request_service_params)
    else
      @request.assign_attributes(request_params)
    end

    @request_item = nil

    if @request.request_form.name != "text"
      @request_item = @request.items.first
      if @request_item
        @request_item.assign_attributes(request_item_params)
      else
        @request_item = @request.items.new(request_item_params)
      end
    end

    if save_request_and_item
      if @transactions.present?
        redirect_to user_request_preview_path(@request.id, transaction_id:@transaction.id)
      else
        redirect_to user_request_preview_path(@request.id)
      end
    else
      if @request.service
        @service = @request.service
      end
      set_edit_values
      render "user/requests/edit"
    end
  end
  
  def save_request_and_item
    if @request_item
      if @request.save && @request_item.save
        true
      else
        false
      end
    else
      if @request.save
        true
      else
        false
      end
    end
  end

  def publish
    if @request.request_form.name == "text" && !@request.is_published
      @request.file = params[:request][:file]
      if @request.items
        @request_item = @request.items.first
        @request_item.update(file: params[:request][:file])
      else
        @request_item = @request.items.create(file: params[:request][:file])
      end
    end
    
    @request.set_publish
    puts "公開済み？"
    puts @request.published_at
    if @transaction #サービスの購入である
      #@request.service = @service
      create_contract
    else #公開依頼のとき
      if @request.save
        flash.notice ="依頼を公開しました"
        redirect_to user_request_path(@request.id)
      else
        detect_models_errors([@transaction, current_user, @request, @service, @request_item])
        flash.notice = "公開できませんでした。"
        @request.set_item_values
        set_preview_values
        render  "user/requests/preview"
      end
    end
  end

  def purchase
    @request.set_publish
    create_contract
  end

  def create_contract
    @transaction.assign_attributes(
      is_contracted:true,
      contracted_at:DateTime.now,
      )
    @service.stock_quantity = @service.stock_quantity-1
    @request.set_service_values
    if all_models_valid?([@transaction, current_user, @request, @service])
      @service.save
      @transaction.save
      @request.save
      current_user.update_total_points
      Email::TransactionMailer.purchase(@transaction).deliver_now
      create_notification
      flash.notice = "購入しました。"
      redirect_to user_request_path(@request.id)
    else
      detect_models_errors([@transaction, current_user, @request])
      flash.notice = "購入できませんでした。"
      @request.set_item_values
      set_preview_values
      render  "user/requests/preview"
    end
  end

  def create
    @request = Request.new(request_params)
    @request_item = @request.items.new(request_item_params)
    @request.user = current_user
    if @request.service_id
      @request.is_inclusive = false
      @service = @request.service
      @transaction = Transaction.new
      @request.set_service_values
      @transaction.assign_attributes(service:@service, request:@request)
      if all_models_valid?([@transaction, current_user, @request, @service])
        if @transaction.save
          redirect_to user_request_preview_path(@request.id, transaction_id:@transaction.id)
        else
          set_new_values
          detect_models_errors([@transaction, current_user, @request, @service])
          render "user/requests/new"
        end
      else
        set_new_values
        detect_models_errors([@transaction, current_user, @request, @service])
        render "user/requests/new"
      end
    else
      @request.is_inclusive = true
      if @request.save 
        redirect_to user_request_preview_path(@request.id)
      else
        set_new_values
        render "user/requests/new"
      end
    end
  end

  def destroy
    #Transactionが存在していないかどうか
    if !Transaction.exists?(request_id:params[:id])
      if @request.destroy
        flash.notice = "削除しました。"
        redirect_to user_requests_path
      else
        flash.notice = "削除できませんでした。"
        redirect_to user_request_path(params[:id])
      end
    else
      flash.notice = "削除できませんでした。"
      redirect_to user_request_path(params[:id])
    end
  end

  def set_new_values
    @service_exist = false
    if @service.present?
      @request.service = @service
      @service_exist = true
      if @service.request
        @original_request = @service.request
      end
      @request_max_characters = @service.request_max_characters
    else
      @request_max_characters = @request.description_max_length
    end
    gon.text_max_length = @request_max_characters
    gon.service_exist = @service_exist
    gon.request_form = @request.request_form.name if @request.request_form
    gon.request_file = nil
    if @service.present?
      gon.request_form = @service.request_form.name
      if @service.request
        gon.request_file = @service.request.file
       end 
    end
    gon.video_extensions = FileUploader.new.extension_allowlist - ImageUploader.new.extension_allowlist
    gon.image_extensions = ImageUploader.new.extension_allowlist
  end

  def set_edit_values
    
    #@service_exist = falseなので意味ない
    @transactions = @request.transactions
    if @transactions.present?
      @transaction = @transactions.first
      @service = @transaction.service
      @service_exist = true
      @request_max_characters = @service.request_max_characters
    else
      @request_max_characters = @request.description_max_length
    end
    
    gon.request_max_length = @request_max_characters
    gon.service_exist = @service_exist
    gon.request_form = @request.request_form.name
    gon.request_file = nil
    gon.video_extensions = FileUploader.new.extension_allowlist - ImageUploader.new.extension_allowlist
    gon.image_extensions = ImageUploader.new.extension_allowlist
    gon.text_max_length = @request_max_characters
  end
  
  def set_preview_values
    @request_published = false
    
    gon.request_form = @request.request_form.name
    gon.request_id = @request.id
    gon.use_youtube = @request.use_youtube
    if @service
      if @request.file.present? #依頼がファイルがある
        gon.is_file_nil = false
      else
        gon.is_file_nil = true
      end
      if @transaction.is_suggestion
        @request_published = true
        @path = user_request_purchase_path(transaction_id: @transaction.id)
      else
        @path = user_request_publish_path
      end
      
      @submit_text = "購入"
      @service_exist = true
    else
      @path = user_request_publish_path
      @submit_text = "公開"
      @service_exist = false
    end

    if !@request.is_inclusive
      @edit_path = edit_user_request_path(@request.id, transaction_id:@transaction.id)
    else
      @edit_path = edit_user_request_path(@request.id)
    end
    gon.request_published = @request_published
  end
  
  private def create_notification
    Notification.create(
      user_id:@service.user_id,
      notifier_id: current_user.id,
      description: "サービスが購入されました。",
      action: "show",
      controller: "requests",
      id_number: @request.id
      )
  end

  private def email_mailer(request)
    NotificationMailer.transaction(request)
  end

  private def create_payment
    #以下直接顧客から回答者に決済をする用の処理
    Stripe::PaymentIntent.create({
      amount: @service.price,
      currency: 'jpy',
      payment_method_types: ['card'],
      customer: @request.user.stripe_customer_id,
      payment_method: @request.user.stripe_card_id,
      confirm:false,
      transfer_data: {
            amount: (@service.price * (1 - transaction_margin.to_f)).to_i,
            destination: @service.user.stripe_account_id,
            }
    })
    #Stripe::Transfer.create(
    #  amount: @service.price,
    #  curreny: 'jpy',
    #  destination: @service.user.stripe_account_id
    #)
  end
  
  private def create_image_from_text
    if @request.request_form.name == "text"
      @text = @request.description
      name = SecureRandom.hex
      @request.file = new_image(name)
      File.delete("./app/assets/images/#{name}.png")
    end
  end

  private def new_image(name) #元々使っていたがライブラリの不具合で今は使っていない
    erb = File.read('./app/views/user/images/answer.html.erb')
    kit = IMGKit.new(ERB.new(erb).result(binding))
    img = kit.to_img(:jpg)
    kit.to_file("./app/assets/images/#{name}.png")
  end

  private def check_stripe
    if !current_user.is_stripe_customer_valid?
      redirect_to  user_cards_path
    end
  end

  private def define_transaction
    if params[:transaction_id]
      @transaction = Transaction.left_joins(:request).find_by(
          id: params[:transaction_id],
          request: {user: current_user}
          )
    elsif params[:service_id] && params[:id]
      @transaction = Transaction.find_by(request_id: params[:id].to_i, service_id: params[:service_id].to_i)
    elsif params[:request]
      if params[:request][:service_id] && params[:id]
        @transaction = Transaction.find_by(service_id: params[:request][:service_id], request_id: params[:id])
      else
        @transaction = false
      end
    else
      @transaction = false
    end
  end

  private def define_request
    if @transaction
      @request = @transaction.request
    elsif params[:id]
      @request = Request.find_by(id:params[:id], user: current_user, is_published:false)
    end
  end

  private def define_service
    if @transaction
      @service = @transaction.service
    elsif params[:service_id]
      @service = Service.find(params[:service_id])
    elsif params[:request] #create  action
      if params[:request][:service_id]
        @service = Service.find(params[:request][:service_id])
      end
    end
  end


  private def check_service_buyable
    if @service
      if !is_service_buyable
        redirect_to user_service_path(@service.id)
        #redirect_back(fallback_location: root_path)
      end
    end
  end

  private def is_service_buyable
    if  @service.stock_quantity < 1
      flash.notice = "売り切れのため購入できませんでした。"
      false
    elsif !@service.is_published
      flash.notice = "サービスが非公開です。"
      false
    elsif !@service.user.is_published
      flash.notice = "ユーザーが非公開です。"
      false
    elsif @service.user.is_deleted
      flash.notice = "アカウントが存在しません。"
      false
    elsif !@service.user.is_stripe_account_valid?
      flash.notice = "回答者の決済が承認されていません。"
      false
    elsif @service.user.state.name != "normal"
      flash.notice = "回答者のアカウントが凍結されています。"
      false
    elsif @service.request
      if @service.request.user == current_user
        true
      else
        flash.notice = "そのサービスは購入できません。"
        false
      end
    else
      true
    end
  end

  private def check_service_updated
    if @service && @request
      if @request.created_at < @service.renewed_at #依頼の作成時刻　<　サービスの更新時刻
        flash.notice = "サービス内容が更新されました"
        redirect_to user_service_path(@service.id)
      end
    end
  end

  private def check_new_at
    if @service
      if params[:request][:new_at].to_datetime < @service.renewed_at #依頼の作成時刻　<　サービスの更新時刻
        flash.notice = "サービス内容が更新されました"
        redirect_to user_service_path(@service.id)
      end
    end
  end

  private def check_budget_sufficient
    if @service
      current_user.update_total_points
      if current_user.total_points < @service.price
        @defficiency = @service.price - current_user.total_points
        flash.notice = "残高が#{@defficiency}ポイント足りません"
        redirect_to user_payments_path(price:@defficiency, controller_name:"user/requests", action_name:"new", id_number:@service.id, price:@service.price, service_id:@service.id)
      end
    end
  end

  private def check_original_request #そのサービスが自分の依頼に対する提案である
    if @service
      if @request
      else
        if !@service.is_inclusive
          @transactions = @service.transactions.left_joins(:request).where(
            is_suggestion:true, 
            request:{user:current_user}
            )
          if @transactions.present?
            @transaction = @transactions.first
            redirect_to user_request_preview_path(@transaction.request.id, transaction_id:@transaction.id)
          end
        end
      end
    end
  end
  
  private def check_previous_request
    if @service
      ordered_request = nil
      ordered_requests = @service.requests.where(user: current_user, is_published:false)
      ordered_requests.each do |request|
        if request.created_at > @service.renewed_at
          ordered_request = request
        end
      end

      puts "既存の依頼"
      puts params[:service_id]
      if ordered_request.present? #依頼しかけのサービスがある
        @transaction = Transaction.find_by(request: ordered_request, service_id: params[:service_id])
        redirect_to user_request_preview_path(ordered_request.id, transaction_id: @transaction.id)
      end
    else
      making_request = Request.find_by(user:current_user, is_inclusive:true, is_published:false)
      if making_request.present?
        redirect_to user_request_preview_path(making_request.id)
      end
    end
  end

  private def request_params
    params.require(:request).permit(
      :title,
      :description,
      :use_youtube,
      :youtube_id,
      :max_price,
      :file,
      :file_duration,
      :thumbnail,
      :category_id,
      :request_form_id,
      :delivery_form_id,
      :service_id,
      :suggestion_deadline,
      :delivery_days
    )
  end

  private def transaction_params
    params.require(:transaction).permit(
      requests_attributes:[]
    )
  end

  private def request_service_params
    params.require(:request).permit(
      :title,
      :description,
      :use_youtube,
      :youtube_id,
      :file,
      :thumbnail,
      :file_duration,
    )
  end

  private def request_item_params
    params.require(:request).permit(
      :file,
      :thumbnail,
      :use_youtube,
      :youtube_id,
      :file_duration,
    )
  end
end

