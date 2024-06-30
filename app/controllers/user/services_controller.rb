class User::ServicesController < User::Base
  before_action :check_login, only:[:new, :edit, :create, :update]
  before_action :define_service, only:[:show, :suggest]
  before_action :check_published, only:[:show]
  before_action :define_transaction, only:[:show]
  before_action :define_request, except:[:transactions, :requests, :reviews]
  before_action :check_user_published, only:[:show]
  before_action :check_request_valid, only:[:new, :create, :edit, :update]
  before_action :check_can_sell_service, only:[:new, :create, :edit, :update]
  before_action :check_can_suggest, only:[:new, :create]
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
      .where("title LIKE?", "%#{params[:word]}%")

    if params[:categories].present?
      @services = @services.where(service_categories: {category_id: params[:categories].split(",").map(&:to_i)})
    end

    if params[:request_form].present?
      @services = @services.where(request_form_name: params[:request_form])
    end

    if params[:delivery_form].present?
      @services = @services.where(delivery_form_name: params[:delivery_form])
    end

    if params[:is_available] == "1"
      @services = @services.where("stock_quantity IS NULL OR stock_quantity >= ?", 1) || @services.stock_quantity.nil?
    end
    #上限価格が入力されている
    if params[:max_price] != nil && params[:max_price] != ""
    @services = @services.where("price <= ?", "#{params[:max_price]}")
    end
    #下限価格が入力されている
    if params[:mini_price] != nil && params[:mini_price] != ""
      @services = @services.where("? <= price", "#{params[:mini_price]}")
    end
    @services = @services.order(total_sales_numbers: :desc, total_views: :desc)
    @services = @services.page(params[:page]).per(24)
  end

  def show
    @relationship = nil
    if @service.user == current_user
      gon.tweet_text = "サービスを出品しました。気になる方は以下のリンクへ！"
    else
      gon.tweet_text = "#{@service.user.name}さんのサービスはこちら。気になる方は以下のリンクへ！"
    end
    gon.env = Rails.env
    if @service.image.url
      @og_image = @service.image.url
    end
    gon.service_id = @service.id
    @og_title = @service.title
    @og_description = @service.description
    @relationship = Relationship.find_by(followee:@service.user, follower_id: current_user.id) if user_signed_in?
    
    #@transactions = @service.transactions
    #@transactions = solve_n_plus_1(@transactions)
    #@transactions = @transactions.where(is_delivered:true)
    #@transactions = @transactions.page(params[:page]).per(5)
  end

  def new
    if params[:request_id]
      @service = Service.new(request: Request.find(params[:request_id]))
    else
      @service = Service.new()
      @service.stock_quantity = nil
      @service.transaction_message_days = nil
    end
    set_form_values
  end

  def edit
    @service = Service.find_by(id: params[:id], user:current_user)
    @service.category_id = @service.category.id
    @submit_text = '更新'
  end

  def create
    @service = Service.new(service_params)
    @service.user = current_user
    @service.total_views = 0
    if @request
      @transaction = Transaction.new(
        service: @service, 
        request: @request, 
        is_suggestion: true
      )
      ActiveRecord::Base.transaction do
        if @service.save && @request.save && @transaction.save
          after_suggest
          redirect_to user_service_path(@service.id)
        else
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
      if @service.save
        create_notification(@service, "相談室を出品されました。")
        flash.alert = "相談室を出品しました。"
        service = Service.find_by(user: current_user)
        redirect_to user_service_path(Service.last.id)
      else
        @request = @service.request
        set_form_values
        render action: "new"
        flash.alert = "相談室を出品できませんでした。"
      end
    end
  end
  
  def update
    @service = Service.find_by(id: params[:id], user:current_user)
    if @service.update(service_update_params)
      if !@service.is_published
        flash.notice = "相談室を非公開にしました。"
        redirect_to user_service_path(params[:id])
      else
        flash.notice = "相談室内容を更新しました。"
        redirect_to user_service_path(params[:id])
      end
    else
      render action: "edit"
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
        redirect_to user_service_path(params[:id])
      end
    else
      flash.notice = "取引が過去に存在するサービスは削除できません。"
      redirect_to user_service_path(params[:id])
    end
  end

  def requests
    @requests = Request
    @requests = @requests.left_joins(:services)
    @requests = solve_n_plus_1(@requests)
    @requests = @requests.where(services: Service.find(params[:id]), is_published: true)
    @requests = @requests.order(id: :DESC)
    @requests = @requests.page(params[:page]).per(5)
    render partial: 'user/services/requests', locals: { contents: @requests }
  end

  def transactions
    @transactions = Transaction.includes(:seller, :service, :request, :items).order(id: :DESC)
    @transactions = @transactions.where(service_id:params[:id], is_delivered: true)
    @transactions = @transactions.page(params[:page]).per(5)
    render partial: "user/services/transactions", locals: { contents: @transactions }
  end

  def reviews
    transactions = Transaction.where(service_id:params[:id], is_delivered: true).where.not(reviewed_at: nil).includes(:seller, :seller, :request).order(id: :DESC)
    @transactions = transactions.page(params[:page]).per(5)
    render partial: "user/services/reviews", locals: { contents: @transactions }
  end

  def suggest
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
      render "user/requests/show"
    end
  end

  private def after_suggest
    Email::ServiceMailer.suggestion(@transaction).deliver_now
    Notification.create(
      user_id: @transaction.request.user.id,
      notifier_id: current_user.id,
      controller: "services",
      action: "show",
      description: "あなたの質問に相談室が提案されました。",
      id_number: @service.id,
      parameter: "?transaction_id=#{@transaction.id}"
    )
    create_notification(@service, "質問に相談室が提案されました。")
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
      redirect_back(fallback_location: root_path)
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

  private def check_can_sell_service
    if !current_user.is_stripe_account_valid?
      redirect_to user_connects_path
      flash.notice = "回答者として登録が完了していません。"
    elsif !current_user.is_seller
      redirect_to edit_user_configs_path
      flash.notice = "回答者として登録してください"
    elsif Service.where(user: current_user, request_id: nil).count > 10
        redirect_to user_account_path(current_user.id)
        flash.notice = "出品できるサービス数が上限に達しています。"
    end
  end

  private def define_service
    @service = Service.find(params[:id])
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
    if !@request.present?
    elsif @request.suggestion_deadline < DateTime.now || !@request.user.is_stripe_customer_valid?
      flash.notice = "その依頼に対して提案できません。"
    end
  end

  private def check_can_suggest
    message = @request&.get_unsuggestable_message(current_user)
    if message
      flash.notice = message
      redirect_to user_request_path(@request.id)
    end
  end

  private def update_total_views
    @service.update(total_views:@service.total_views + 1)
  end

  
  def create_notification(service, text)
    relationships = Relationship.where(followee: current_user)
    relationships.each do |relationship|
      Notification.create(
        user: relationship.follower,
        notifier_id: current_user.id,
        description: text,
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
      :image,
      :category_id,
      :transaction_message_days,
      :stock_quantity,
      :close_date,
      :delivery_days,
      :request_max_minutes,
      :request_max_characters,
      :request_form_name,
      :delivery_form_name,
      :request_id,
      :is_published
    )
  end

  private def service_update_params
    params.require(:service).permit(
      :title,
      :description,
      :price,
      :image,
      :category_id,
      :transaction_message_days,
      :stock_quantity,
      :close_date,
      :delivery_days,
      :request_form_name,
      :delivery_form_name,
      :request_id,
      :request_max_minutes,
      :request_max_characters,
      :is_published
    )
  end
end
