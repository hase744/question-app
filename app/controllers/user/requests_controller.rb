class User::RequestsController < User::Base
  before_action :check_login, only:[:new, :create, :edit, :destroy, :update, :preview, :edit, :publish, :retract, :create_message, :answer ] #ログイン済みである
  before_action :display_payment_message, only:[:preview]
  before_action :define_transaction, only:[ :publish, :preview , :update, :publish, :purchase, :edit]
  before_action :define_own_request, only:[:create, :edit, :destroy, :update, :preview, :publish, :purchase]
  before_action :define_request, only:[:show, :message_cells]
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
  before_action :check_can_check_request, only:[:show]
  before_action :check_can_create_service, only:[:create_message, :answer]
  before_action :check_can_answer, only:[:answer, :create_message]
  before_action :can_create_request, only: [:new, :publish, :purchase]
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
      .filter_categories(params[:category_names])
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
    @post_page = 5
    @transaction = current_user&.sales&.find_by(request: @request)
    @transaction_message = @transaction.transaction_messages.new() if @transaction
    if user_signed_in?
      @relationship = Relationship.find_by(user: @request.user, target_user_id: current_user.id)
    end
    @request.update(total_views:@request.total_views + 1)
    params[:page] ||= 1
    @models = @request.message_records
      .where(only_answer: params[:only_answer], order: params[:order])
      .page(params[:page].to_i).per(20)
  end

  def new
    if params[:request]
      @request = Request.new(request_params)
    else
      @request = Request.new(service_id:params[:service_id])
      @request.request_categories.build
    end
    @request.items.build
  end

  def edit
    @request.service = @transaction&.service if @transaction
    @request.request_categories.build
    @request.items.build
  end

  def preview
    set_preview_values
  end

  def retract
    request = Request.find_by(id: params[:id], user:current_user, is_inclusive: true)
    request.set_retraction
    if request.save
      flash.notice = "質問を取り下げました"
    else
      flash.notice = "質問を取り下げできませんでした。\r\n#{request.errors_messages}"
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

  def publish
    @request.set_publish
    if @request.need_text_image?
      @item = @request.build_item
      @item.process_file_upload = false
      if params[:request][:file].present?
        @item.assign_attributes(file: params[:request][:file], is_text_image: true)
      else
        html_content, css_content = generate_html_css_from_request(@request)
        @item.assign_image_from_content(html_content, css_content)
      end
    end
    if @transaction #サービスの購入である
      @request.service = @service
      if create_contract #validationのため、先に文章画像を保存
        redirect_to user_request_path(@request.id, @parameters)
        return
      else
        flash.notice = "購入できませんでした。"
      end
    else #公開依頼のとき
      if save_models_at_once
        flash.notice ="質問を公開しました"
        redirect_to user_request_path(@request.id, @parameters)
        return
      else
        flash.notice = "公開できませんでした。"
      end
    end
    detect_models_errors([@transaction, current_user, @request, @service, @request_item])
    #@item&.delete_temp_file
    #@item&.destroy
    set_preview_values
    render "user/requests/preview"
  end

  def purchase
    @request.set_publish
    if create_contract
      redirect_to user_request_path(@request.id)
    else
      render  "user/services/show"
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

  def create_message
    @request = Request.find(params[:id])
    check_transaction(redirect_path: user_request_path(@request, open_message_modal: true))
  end

  def answer
    check_transaction(redirect_path: -> { edit_user_transaction_path(@transaction.id) })
  end

  def check_transaction(redirect_path:)
    @request = Request.find(params[:id])
    @transaction = current_user.sales.find_by(request: @request)
    if @transaction
      redirect_to redirect_path.is_a?(Proc) ? redirect_path.call : redirect_path
    else
      ActiveRecord::Base.transaction do
        @service = Service.new(
          user: current_user, 
          mode: 'reward', 
          price: 0,
          request_form_name: @request.request_form_name,
          delivery_form_name: @request.delivery_form_name
          )
        @service.service_categories.build(category_name: @request.category.name)
        @transaction = Transaction.new(
          service: @service, 
          request: @request, 
          price: 0,
          mode: 'reward'
        )
        if save_models
          redirect_to redirect_path.is_a?(Proc) ? redirect_path.call : redirect_path
        else
          flash.notice = "失敗しました。#{@transaction.errors_messages}"
          redirect_back(fallback_location: root_path)
        end
      end
    end
  end

  def generate_items
    return [] unless params.dig(:items, :file).present?
    params.dig(:items, :file)&.map do |file|
      item = @request.items.build
      item.process_file_upload = false
      item.file = file
      item 
    end
  end
  
  def set_preview_values
    if @service
      @submit_text = "購入"
      @request.service = @transaction.service
      @deficient_point = [@transaction.required_points - current_user.total_points, 0].max
      @payment = Payment.new(point: @deficient_point || 100)
    else
      @submit_text = "公開"
    end

    if @request.mode == 'reward'
      @deficient_point = [@request.required_points - current_user.total_points, 0].max
      @payment = Payment.new(point: @deficient_point || 100)
    end

    if @request.is_inclusive
      @edit_path = edit_user_request_path(@request.id)
    else
      @edit_path = edit_user_request_path(@request.id, transaction_id:@transaction.id)
    end
  end

  private def check_can_check_request
    if !@request.is_published
      flash.notice = "質問が非公開です。"
      redirect_to user_requests_path
    elsif !@request.user.is_published
      flash.notice = "アカウントが非公開です。"
      redirect_to user_requests_path
    elsif @request.user.is_deleted
      flash.notice = "アカウントが存在しません。"
      redirect_to user_requests_path
    end
  end

  private def check_can_create_service
    if !current_user.is_seller
      redirect_to edit_user_accounts_path
      flash.notice = "回答者として登録してください"
    end
  end

  private def create_contract
    @transaction.set_contraction
    @transaction.build_coupon_usages
    @request.set_service_values
    if save_models_at_once
      EmailJob.perform_later(mode: :purchase, model: @transaction) if @transaction.seller.can_email_transaction
      create_notification
      flash.notice = "購入しました。"
      true
    else
      false
    end
  end

  private def save_models_at_once
    ActiveRecord::Base.transaction do
      if save_models
        true
      else
        false
      end
    end
  end

  private def create_notification
    Notification.create(
      user_id: @service.user_id,
      notifier_id: current_user.id,
      published_at: DateTime.now,
      title: "相談室に質問が届きました",
      description: @request.title,
      action: "show",
      controller: "orders",
      id_number: @transaction.id
      )
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
  end

  private def check_stripe_customer
    return if current_user.is_stripe_customer_valid? || @transaction&.required_points == 0
    flash.notice = "クレジットカードを登録してください"
    redirect_to  new_user_cards_path
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
    end
  end

  private def define_own_request
    if @transaction
      @request = @transaction.request
    elsif params[:id]
      @request = Request.find_by(id:params[:id], user: current_user, is_published:false)
    end
  end

  private def define_request
    if params[:id]
      @request = Request.find_by(id:params[:id])
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
    flash.notice = "残高が#{@defficiency}ポイント不足しています"
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

  private def check_can_answer
    if !current_user.is_seller
      redirect_to edit_user_accounts_path
      flash.notice = "回答者として登録してください"
    end
  end

  private def request_params
    params.require(:request).permit(
      :title,
      :description,
      :max_price,
      :image,
      :file_duration,
      :thumbnail,
      :category_id,
      :request_form_name,
      :delivery_form_name,
      :service_id,
      :suggestion_deadline,
      :suggestion_acceptable_days, 
      :mode,
      :reward,
      request_categories_attributes: [:category_name],
    )
  end

  private def request_new_params
    params.require(:request).permit(
      :title,
      :description,
      :max_price,
      :image,
      :file_duration,
      :thumbnail,
      :category_id,
      :request_form_name,
      :delivery_form_name,
      :service_id,
      :suggestion_deadline,
      :suggestion_acceptable_days, 
      :mode,
      :reward,
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
      :file,
      :thumbnail,
      :file_duration,
    )
  end

  private def request_item_params
    params.require(:request).permit(
      :file,
      :thumbnail,
      :file_duration,
    )
  end

  private def can_create_request
    last_reward_request = current_user.requests
      .published
      .deadline_over
      .reward_mode
      .from_latest_order&.first
    if last_reward_request&.is_accepting && last_reward_request&.remaining_reward > 0
      flash.notice = "報酬の支払いが完了していない、または質問の取り下げが未完了の状態では、新たに質問を作成することはできません。"
      redirect_to user_request_path(last_reward_request.id)
    end
  end
end