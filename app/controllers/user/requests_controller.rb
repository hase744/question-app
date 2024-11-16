class User::RequestsController < User::Base
  before_action :check_login, only:[:new, :create, :edit, :destroy, :update, :preview, :edit, :publish, :stop_accepting ] #ログイン済みである
  before_action :define_transaction, only:[ :publish, :preview , :update, :publish, :purchase, :edit]
  before_action :define_request, only:[:create, :edit, :destroy, :update, :preview, :publish, :purchase]
  before_action :define_service, only:[:new, :create, :edit, :destroy, :update, :preview, :publish, :purchase]
  before_action :define_parameter, except:[:new]
  before_action :check_request_need_transaction, only:[:edit, :preview]
  before_action :check_stripe_customer, only:[:publish, :purchase] #Stripeのアカウントが有効である
  before_action :check_service_buyable, only:[:new, :edit, :create, :update, :previous, :publish] #サービスが購入可能である
  before_action :check_service_checked_at, only:[:preview, :edit, :create, :update, :publish]
  before_action :check_original_request, only:[:new, :create, :preview] #購入しようとしているサービスが自分の依頼に対する提案である
  before_action :check_previous_request, only:[:new, :create] #以前に購入しようとしたことがある
  before_action :check_already_contracted, only:[:new, :create, :publish, :purchase, :preview, :edit]
  before_action :check_budget_sufficient, only:[:publish, :purchase]
  layout :choose_layout

  private def choose_layout
    case action_name
    when "show"
      "medium_layout"
    when "purchase"
      "responsive_layout"
    when "index"
      "search_layout"
    else
      "small"
    end
  end

  def index
    @requests = Request.includes(:user)
      .suggestable
      .filter_categories(params[:categories])
    @requests = @requests.where("requests.title LIKE ?", "%#{params[:word]}%") if params[:word].present?

    if params[:request_form].present?
      @requests = @requests.where(request_form_name: params[:request_form])
    end

    if params[:delivery_form].present?
      @requests = @requests.where(delivery_form_name: params[:delivery_form])
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

    @requests = @requests.sorted_by(params[:order])
    @requests = @requests.page(params[:page]).per(10)
  end

  def show
    @request = Request.find(params[:id])
    if !@request.is_published
      flash.notice = "質問が非公開です。"
      redirect_to user_requests_path
    elsif !@request.user.is_published
      flash.notice = "アカウントが非公開です。"
      redirect_to user_requests_path
    elsif @request.user.is_deleted
      flash.notice = "アカウントが存在しません。"
      redirect_to user_requests_path
    else
      if user_signed_in?
        @relationship = Relationship.find_by(user: @request.user, target_user_id: current_user.id)
      end
      @request.update(total_views:@request.total_views + 1)
    end
  end

  def new
    if params[:request]
      @request = Request.new(request_params)
      @request.set_item_values
    else
      @request = Request.new(service_id:params[:service_id])
      @request.request_categories.build
    end
    @request.items.build
  end

  def edit
    @request.service = @transaction&.service if @transaction
    @request.set_item_values
    @request.request_categories.build
    @request.items.build
  end

  def preview
    if @transaction
      @request.service = @transaction.service
    end
    @request.set_item_values
    set_preview_values
  end

  def stop_accepting
    if Request.find_by(id: params[:id], user:current_user, is_inclusive: true).update(is_accepting: false)
      flash.notice = "質問を取り下げました"
    else
      flash.notice = "質問を取り下げできませんでした"
    end
    redirect_back(fallback_location: root_path)
  end

  def mine
    @requests = current_user.requests
      .solve_n_plus_1
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)
  end

  def update
    @transactions = Transaction.where(request:@request) #サービスの購入である
    if @transactions.present? #サービスの購入である
      @request.assign_attributes(request_service_params)
      @request.service = @service
    end

    @request.assign_attributes(request_params)
    @items = generate_items&.flatten
    ActiveRecord::Base.transaction do
      if save_models
        if @request.request_form.name == "text" && !@request.is_published
          @request.items.delete_all
        end
        if @transactions.present?
          redirect_to user_request_preview_path(@request.id, transaction_id:@transaction.id)
        else
          redirect_to user_request_preview_path(@request.id)
        end
      else
        delete_temp_file_items
        @request.request_categories.reject(&:persisted?).each do |category|
          @request.request_categories.delete(category) #これがないとcateogryフィールドが複数生成される
        end
        if @request.service
          @service = @request.service
        end
        render "user/requests/edit"
      end
    end
  end

  def remove_file
    @request_item = RequestItem.find(params[:id])
    @request = @request_item.request
    if @request_item.delete
      flash.notice = "削除しました"
      redirect_back(fallback_location: root_path)
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
    @request.set_publish
    if @request.need_text_image?
      @item = @request.items.new()
      @item.process_file_upload = false
      @item.assign_attributes(file: params[:request][:file], is_text_image: true)
    end
    if @transaction #サービスの購入である
      @request.service = @service
      if save_item && create_contract #validationのため、先に文章画像を保存
        redirect_to user_request_path(@request.id, @parameters)
      else
        @item&.delete_temp_file
        @item&.destroy
        render "user/requests/preview"
      end
    else #公開依頼のとき
      @request.suggestion_deadline = Time.now + @request.suggestion_acceptable_duration
      if save_item && @request.save
        flash.notice ="質問を公開しました"
        redirect_to user_request_path(@request.id, @parameters)
      else
        detect_models_errors([@transaction, current_user, @request, @service, @request_item])
        @item&.delete_temp_file
        @item&.destroy
        flash.notice = "公開できませんでした。"
        @request.set_item_values
        set_preview_values
        render "user/requests/preview"
      end
    end
  end

  def save_item
    @item ? @item.save : true
  end

  def purchase
    @request.set_publish
    if create_contract
      redirect_to user_request_path(@request.id)
    else
      render  "user/services/show"
    end
  end

  def create_contract
    @transaction.assign_attributes(
      is_contracted:true,
      contracted_at:DateTime.now,
      delivery_time: DateTime.now + @service.delivery_days.to_i
      )
    @transaction.build_coupon_usages
    #@service.stock_quantity = @service.stock_quantity-1 if @service.stock_quantity
    @request.set_service_values

    ActiveRecord::Base.transaction do
      if save_models
        EmailJob.perform_later(mode: :purchase, model: @transaction) if @transaction.seller.can_email_transaction
        create_notification
        flash.notice = "購入しました。"
        true
      else
        puts "失敗 #{@request.items.count}"
        #flash.notice = "購入できませんでした。" +
        #[@service.errors.full_messages,
        # @request.errors.full_messages,
        # @transaction.errors.full_messages].flatten.join("\n")
        @request.set_item_values
        set_preview_values
        false
      end
    end
  end

  def create
    @request = Request.new(request_new_params)
    #@request_item = @request.items.new(request_item_params)
    @request.user = current_user
    @request.is_accepting = true
    @items = generate_items&.flatten
    if @request.service_id
      @request.is_inclusive = false
      @service = @request.service
      @transaction = Transaction.new
      @request.set_service_values
      @transaction.assign_attributes(service:@service, request:@request)
      #↓なぜか出来ないのでafter_saveで生成
      #@transaction.transaction_categories.build(category_name: @service.category.name)
      ActiveRecord::Base.transaction do
        if save_models
          redirect_to user_request_preview_path(@request.id, transaction_id:@transaction.id)
        else
          delete_temp_file_items
          detect_models_errors([@transaction, @request])
          render "user/requests/new"
        end
      end
    else
      @request.is_inclusive = true
      ActiveRecord::Base.transaction do
        if save_models
          redirect_to user_request_preview_path(@request.id)
        else
          render "user/requests/new"
        end
      end
    end
  end

  def destroy
    #Transactionが存在していないかどうか
    if !Transaction.exists?(request_id:params[:id])
      @request = Request.find_by(id:params[:id], user: current_user)
      if @request.destroy
        flash.notice = "削除しました。"
        redirect_to user_requests_path
      else
        flash.notice = "削除できませんでした。"
        redirect_to user_request_path(params[:id])
      end
    else
      flash.notice = "取引・提案のある質問は削除できません。"
      redirect_to user_request_path(params[:id])
    end
  end

  def generate_items
    return [] unless params.dig(:items, :file).present?
    params.dig(:items, :file)&.map do |file|
      item = @request.items.new()
      item.process_file_upload = false
      item.file = file
      item 
    end
  end
  
  def set_preview_values
    if @service
      if @transaction.is_suggestion
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
  end

  private def create_notification
    Notification.create(
      user_id: @service.user_id,
      notifier_id: current_user.id,
      title: "あなたの相談室に相談が依頼されました",
      description: @request.title,
      action: "show",
      controller: "orders",
      id_number: @transaction.id
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

  private def check_stripe_customer
    unless current_user.is_stripe_customer_valid? || @transaction&.required_points == 0
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
      @transaction = Transaction.find_by(request_id: params[:id], service_id: params[:service_id])
    elsif params.dig(:request, :service_id) && params[:id]
      @transaction = Transaction.find_by(
        service_id: params[:request][:service_id], 
        request_id: params[:id]
        )
    else
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
    elsif params.dig(:request, :service_id).present? #create  action
      @service = Service.find(params[:request][:service_id])
    end
  end

  private def define_parameter
    @parameters = @transaction ? { transaction_id: @transaction.id } : {}
  end

  private def check_service_buyable
    flash.notice = @service&.get_unbuyable_message(current_user)
    if flash.notice.present?
      redirect_to user_service_path(@service.id)
    end
  end

  private def check_service_checked_at
    if @service && @transaction && @request
      if @transaction.service_checked_at < @service.renewed_at #依頼の作成時刻　<　サービスの更新時刻
        @transaction.copy_from_service
        @transaction.service_checked_at = DateTime.now
        @request.service = @service
        @request.copy_from_service
        if save_models
          flash.notice = "相談室の内容が変更されました"
          redirect_to user_service_path(@service.id)
        else
          @request.destroy
          @transaction.destroy
          flash.notice = "エラーが発生しました"
          redirect_to user_service_path(@service.id)
        end
      end
    end
  end

  private def check_budget_sufficient
    return if @service.nil? 
    return if current_user.total_points >= @transaction.required_points
    @defficiency = @service.price - current_user.total_points
    flash.notice = "残高が#{@defficiency}ポイント足りません"
    session[:payment_service_id] = @service.id
    session[:payment_transaction_id] = @transaction.id
    redirect_to user_payments_path(point:@defficiency)
  end

  private def check_already_contracted
    if @transaction&.is_contracted
      flash.notice = "購入済みです"
      redirect_to user_service_path(@service.id, transaction_id: @transaction.id)
    end
  end

  private def check_original_request #そのサービスが自分の依頼に対する提案である
    if @service&.request&.user == current_user
      redirect_to user_service_path(@service.exclusive_transaction.id)
    end
  end
  
  private def check_previous_request
    if @service
      ordered_request = nil
      ordered_request = @service.requests.find_by(user: current_user, is_published:false)
      #ordered_requests.each do |request|
      #  if request.created_at > @service.renewed_at
      #    ordered_request = request
      #  end
      #end

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

  private def check_request_need_transaction
    if !defined?(@transaction) && @request.transactions.count > 0
      redirect_to user_request_path(request_id: @request.id)
    end
  end

  private def request_params
    params.require(:request).permit(
      :title,
      :description,
      :use_youtube,
      :youtube_id,
      :max_price,
      :image,
      :file_duration,
      :thumbnail,
      :category_id,
      :request_form_name,
      :delivery_form_name,
      :service_id,
      :suggestion_deadline,
      :delivery_days, 
      request_categories_attributes: [:category_name],
    )
  end

  private def request_new_params
    params.require(:request).permit(
      :title,
      :description,
      :use_youtube,
      :youtube_id,
      :max_price,
      :image,
      :file_duration,
      :thumbnail,
      :category_id,
      :request_form_name,
      :delivery_form_name,
      :service_id,
      :suggestion_deadline,
      :delivery_days, 
      request_categories_attributes: [:category_name],
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