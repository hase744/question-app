class User::ServicesController < User::Base
  before_action :check_login, only:[:new, :edit, :create, :update, :history]
  before_action :define_service, only:[:show, :suggest]
  before_action :define_own_service, only:[:edit, :update]
  before_action :check_published, only:[:show]
  before_action :define_transaction, only:[:show]
  before_action :define_request, except:[:transactions, :requests, :reviews]
  before_action :check_user_published, only:[:show]
  #before_action :check_request_valid, only:[:new, :create, :edit, :update]
  before_action :check_can_create_service, only:[:new, :create, :edit, :update]
  #before_action :check_can_sell_service, only:[:new, :create, :edit, :update]
  before_action :check_can_suggest, only:[:new, :create, :edit, :update]
  before_action :check_service_valid, only:[:edit, :update]
  before_action :define_page_count
  after_action :update_total_views, only:[:show]
  layout :choose_layout

  private def choose_layout
    case action_name
    when "show"
      "responsive_layout"
    when "suggest"
      "responsive_layout"
    when "index"
      "search_layout"
    else
      "small"
    end
  end

  def index
    @services = Service
      .seeable
      .filter_categories(params[:category_names])
    @services = @services.where("services.title LIKE ?", "%#{params[:word]}%") if params[:word].present?

    if params[:request_form].present?
      @services = @services.where(request_form_name: params[:request_form])
    end

    if params[:delivery_form].present?
      @services = @services.where(delivery_form_name: params[:delivery_form])
    end

    if params[:is_available] == "1"
      @services = @services.where(is_for_sale: true)
    end
    #上限価格が入力されている
    if params[:max_price].present?
      @services = @services.where("services.price <= ?", "#{params[:max_price]}")
    end
    #下限価格が入力されている
    if params[:mini_price].present?
      @services = @services.where("? <= services.price", "#{params[:mini_price]}")
    end
    @services = @services.sorted_by(params[:order])
    @services = @services.page(params[:page]).per(24)
  end

  def show
    if @service.user == current_user
      @tweet_text = 
      "「稼げる相談サイト」コレテクで相談室を出品しました。「#{@service.title}」という内容を提供します。気になる方は以下のリンクへ！"
    else
      @tweet_text = 
      "「稼げる相談サイト」コレテクの#{@service.user.name}さんの相談室はこちら。 気になる方は以下のリンクへ！"
    end

    if @transaction
      @deficient_point = [@transaction.required_points - current_user.total_points, 0].max
      @payment = Payment.new(point: @deficient_point || 100)
    end

    if @service.item&.file&.url
      $og_image = @service.item&.file&.url
    end
    @og_title = @service.title
    @og_description = @service.description

    set_current_nav_item_for_service
    @bar_elements = [
      {item:'transactions',japanese_name:'回答', link:user_service_transactions_path(@service.id, nav_item:'transactions'), page:@transaction_page, for_seller:true},
      {item:'requests',japanese_name:'質問', link:user_service_requests_path(@service.id, nav_item:'requests'), page:@request_page, for_seller:false},
      {item:'reviews',japanese_name:'レビュー', link:user_service_reviews_path(@service.id, nav_item:'reviews'), page:@review_page, for_seller:true},
    ]

    case current_nav_item
    when 'transactions'
      @models = Transaction.where(service: @service, is_published: true)
    when 'requests'
      @models = Request.from_service(@service)
    when 'reviews'
      @models = @service.transactions.reviewed
    end

    current_element = @bar_elements.find{|e| 
      e[:item] == current_nav_item
    }

    @models = @models
      .solve_n_plus_1
      .order(id: :DESC)
      .page(params[:page])
      .per(current_element[:page])
  end

  def new
    if params[:request_id]
      @service = Service.new(request: Request.find(params[:request_id]))
      @request.request_categories.each do |rc|
        @service.service_categories.build(category_name: rc.category_name)
      end
    else
      @service = Service.new()
      @service.service_categories.build
    end
    set_form_values
  end

  def edit
    @submit_text = '更新'
  end

  def create
    @service = Service.new(service_params)
    @service.user = current_user
    @service.total_views = 0
    if params.dig(:item, :file)
      @item = @service.items.new()
      @item.process_file_upload = false
      @item.assign_attributes(file: params.dig(:item, :file)[0])
    end
    if @request
      @transaction = Transaction.new(
        service: @service, 
        request: @request, 
        is_suggestion: true
      )
      if @service.service_categories.length == 0
        #@service.service_categories.new(category_name: @request.category.name)
      end
      ActiveRecord::Base.transaction do
        if save_models
          after_suggest
          redirect_to user_service_path(@service.id)
        else
          delete_temp_file_items
          @request = @service.request
          set_form_values
          render action: "new"
          flash.alert = "相談室を提案できませんでした。" +
          [@service.errors.full_messages,
           @request.errors.full_messages,
           @transaction.errors.full_messages].flatten.join("\n")
        end
      end
    else
      ActiveRecord::Base.transaction do
        if save_models
          create_notification(@service, "相談室が出品されました。")
          flash.alert = "相談室を出品しました。"
          service = Service.find_by(user: current_user)
          redirect_to user_service_path(@service.id)
        else
          @request = @service.request
          delete_temp_file_items 
          set_form_values
          render action: "new"
          flash.alert = "相談室を出品できませんでした。"
        end
      end
    end
  end
  
  def update
    @service.assign_attributes(service_params)
    if params.dig(:item, :file).present?
      @item = @service.item
      unless @item.present?
        @item = @service.items.new
      end
      @item.process_file_upload = false
      @item.assign_attributes(file: params.dig(:item, :file)[0])
    end
    ActiveRecord::Base.transaction do
      if save_models
        if !@service.is_published
          flash.notice = "相談室を非公開にしました。"
          redirect_to user_service_path(params[:id])
        else
          flash.notice = "相談室を更新しました。"
          redirect_to user_service_path(params[:id])
        end
      else
        delete_temp_file_items
        @service.service_categories.reject(&:persisted?).each do |category|
          @service.service_categories.delete(category) #これがないとcateogryフィールドが複数生成される
        end
        render action: "edit"
      end
    end
  end

  def destroy
    @service = Service.find_by(id: params[:id], user:current_user)
    #Transactionが存在していないかどうか
    if !Transaction.exists?(service_id:params[:id])
      if @service.destroy
        flash.notice = "削除しました。"
        redirect_to user_services_path
      else
        flash.notice = "削除できませんでした。"
      end
    elsif @service.request_id
      flash.notice = "提案済みのサービスは削除できません。"
    else
      flash.notice = "取引が既に存在するサービスは削除できません。"
    end
    redirect_to user_service_path(params[:id])
  end

  def requests
    @requests = Request
    @requests = @requests.left_joins(:services)
    @requests = @requests.solve_n_plus_1
    @requests = @requests.where(services: Service.find(params[:id]), is_published: true)
    @requests = @requests.order(id: :DESC)
    @requests = @requests.page(params[:page]).per(@request_page)
    render partial: 'user/requests/cell', collection: @requests, as: :request
  end

  def transactions
    @transactions = Transaction.includes(:seller, :service, :request, :items).order(id: :DESC)
    @transactions = @transactions.where(service_id:params[:id], is_published: true)
    @transactions = @transactions.page(params[:page]).per(@transaction_page)
    render partial: 'user/transactions/answer', collection: @transactions, as: :transaction
  end

  def reviews
    transactions = Transaction.solve_n_plus_1
      .reviewed
      .where(service_id:params[:id])
      .order(id: :DESC)
    @transactions = transactions.page(params[:page]).per(@review_page)
    render partial: 'user/reviews/cell', collection: @transactions, as: :transaction
  end

  def suggest
    if message = @service.get_unsuggestable_message(@request)
      flash.notice = message
      redirect_back(fallback_location: root_path)
      return
    end
    @transaction = Transaction.new(
      service: @service, 
      request: @request, 
      is_suggestion:true
      )
    if @transaction.save
      after_suggest
      redirect_to user_service_path(params[:id], transaction_id: @transaction.id)
    else
      flash.alert = @transaction.errors.full_messages.to_sentence
      @transactions = @request.transactions.where(
        is_contracted: true,
        is_rejected: false
        )
      redirect_back(fallback_location: root_path)
    end
  end

  def mine
    @services = current_user.services
      .proposal_mode
      .solve_n_plus_1
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)
  end

  private def after_suggest
    Email::ServiceMailer.suggestion(@transaction).deliver_now
    Notification.create(
      user_id: @transaction.request.user.id,
      notifier_id: current_user.id,
      controller: "services",
      action: "show",
      title: "質問に相談室が提案されました",
      description: @transaction.service.title,
      id_number: @service.id,
      parameter: "?transaction_id=#{@transaction.id}"
    )
    flash.alert = "相談室を提案しました"
  end

  private def set_form_values
    if @request.present?
      @service.delivery_days = (@request.suggestion_deadline.to_datetime - DateTime.now).to_i
      @submit_text = "提案"
    else
      @submit_text = "出品"
    end
  end

  private def check_published
    #サービスが非公開かつ、サービス作成者ではない時redirectさせる
    if @service.is_published #公開=>誰でもアクセス
    elsif user_signed_in? && @service.user == current_user
      #非公開だけどユーザー本人
    else
      flash.notice = "相談室が非公開です。"
      redirect_to user_services_path
    end
  end
  
  private def check_user_published
    @service = Service.find(params[:id])
    if !@service.user.is_published
      flash.notice = "アカウントが非公開です。"
      redirect_to user_services_path
    elsif @service.user.is_deleted
      flash.notice = "アカウントが存在しません。"
      redirect_to user_services_path
    end
  end

  private def check_can_create_service
    if !current_user.is_seller
      redirect_to edit_user_accounts_path
      flash.notice = "回答者として登録してください"
    elsif Service.where(user: current_user, request_id: nil).proposal_mode.count > 10
        redirect_to user_account_path(current_user.id)
        flash.notice = "出品できる相談室数が上限に達しています。"
    end
  end

  private def define_page_count
    @request_page = 5
    @transaction_page = 5
    @review_page = 5
  end

  private def define_service
    @service = Service.proposal_mode.find_by(id: params[:id])
  end

  private def define_own_service
    @service = Service.proposal_mode.find_by(id: params[:id], user: current_user)
  end

  private def define_transaction
    if @service.request_id
      @transaction = @service.exclusive_transaction
    elsif params[:transaction_id]
      @transaction = Transaction.find(params[:transaction_id])
    end
  end

  private def define_request
    if params[:request_id]
      @request = Request.find(params[:request_id])
    elsif params.dig(:service, :request_id)
        @request = Request.find(params.dig(:service, :request_id))
    elsif params[:id]
        @request = Service.find(params[:id]).request
    end
  end

  private def check_request_valid
    return unless @request
    if @request.suggestion_deadline < DateTime.now || !@request.user.is_stripe_customer_valid?
      flash.notice = "その依頼に対して提案できません。"
      redirect_back(fallback_location: root_path)
    end
  end

  private def check_can_suggest
    message = @request&.get_unsuggestable_message(current_user)
    if message
      flash.notice = message
      redirect_to user_request_path(@request.id)
    end
  end

  private def check_service_valid
    if @service.is_disabled
      flash.notice = "相談室が無効になため修正できません"
      redirect_back(fallback_location: root_path)
    end
  end

  private def update_total_views
    @service.update(total_views:@service.total_views + 1)
  end

  def create_notification(service, text)
    current_user.followers.each do |user|
      Notification.create(
        user: user,
        notifier_id: current_user.id,
        title: text,
        description: service.title,
        action: "show",
        controller: "services",
        id_number: service.id
        )
    end
  end

  private def service_params
    params.require(:service).permit(
      :title,
      :description,
      :price,
      :category_id,
      :transaction_message_enabled,
      :close_date,
      :delivery_days,
      :request_max_minutes,
      :request_max_characters,
      :request_form_name,
      :delivery_form_name,
      :request_id,
      :is_published,
      :is_for_sale,
      :allow_pre_purchase_inquiry,
      service_categories_attributes: [:category_name],
    )
  end
end
