class User::TransactionsController < User::Base
  #layout "search_layout", only: :index
  before_action :check_login, only:[:new, :create, :edit, :update, :create_description_image, :like, :messages]
  before_action :define_transaction, only:[:show, :edit, :update, :deliver, :messages, :like]
  before_action :define_own_transaction, only:[:preview]
  before_action :filter_transaction, only:[:update, :deliver]
  before_action :check_transaction_published, only:[:show, :like]
  before_action :check_transaction_not_published, only:[:edit, :public]
  before_action :check_can_publish, only: [:edit, :update, :preview]
  before_action :identify_seller, only:[:edit, :update, :create_description_image]
  before_action :define_transaction_message, only:[:show, :messages]
  #before_action :check_can_send_message, only:[:messages]
  after_action :update_total_views, only:[:show]
  layout :choose_layout

  private def choose_layout
    case action_name
    when "show"
      "responsive_layout"
    when "index"
      "search_layout"
    when "messages"
      "medium_layout"
    else
      "small"
    end
  end

  def index
    @transactions = Transaction.valid
    @transactions = @transactions.joins(:transaction_categories)
    @transactions = @transactions.distinct
    @transactions = @transactions.solve_n_plus_1
    @transactions = @transactions.where(is_published:true)
    @transactions = @transactions.filter_categories(params[:category_names])
    @transactions = @transactions.where("transactions.title LIKE ?", "%#{params[:word]}%") if params[:word].present?
    @transactions = @transactions.page(params[:page]).per(30)
    @transactions = @transactions.sorted_by(params[:order])
  end

  def edit
    unless can_edit_transaction
      redirect_to user_order_path(params[:id])
    end
    @preview_path = @transaction.is_reward_mode? ? preview_user_transaction_path(params[:id]) : user_order_path(@transaction.id)
    @transaction.items.build
  end

  def preview
  end

  def show
    $og_image = @transaction.request.items.first.file.url if @transaction.request.items.select{|item| item.file.is_image?}.present?
    @transaction_along_messages =  @transaction
      .transaction_messages
      .before_transaction_published
      .after_request_published
      #.where('transaction_messages.created_at > transactions.contracted_at')
    @tweet_text = @transaction.description
    @transaction_message = TransactionMessage.new()

    #@transactionの前にアップロードされた取引と後にアップロードされた取引の数を比較し多い方をおすすめとして表示
    @transactions = Transaction.solve_n_plus_1
      .left_joins(:transaction_categories)
      .valid
      .distinct
      .includes(:seller, :service, :request, :items, :transaction_categories)
      .where.not(id: @transaction.id)
      .where(
        is_published:true, 
        transaction_categories:{category_name: @transaction.category.name}
        )
    @total_message_count = @transaction.total_after_published_messages
    transactions = @transactions.where(id: ..@transaction.id).order(created_at: "ASC").limit(10)
    @transactions = @transactions.where(id: @transaction.id..).order(created_at: "ASC").limit(10)
    if @transactions.count < transactions.count
      @transactions = transactions
    end
    @like = TransactionLike.find_by(user:current_user, transaction_id: params[:id])
  end

  def create_description_image
    @transaction = Transaction.find(params[:id])
    if !@transaction.is_transacted && params[:transaction][:file]
      @transaction.update(file: params[:transaction][:file])
    end
  end

  def update
    @transaction.assign_attributes(transaction_params)
    @transaction.category.name
    @items = generate_items&.flatten
    ActiveRecord::Base.transaction do
      if save_models
        flash.notice = "回答を編集しました"
        path = @transaction.is_reward_mode? ? preview_user_transaction_path(params[:id]) : user_order_path(params[:id])
        redirect_to path
      else
        delete_temp_file_items
        detect_models_errors([@transaction.item, @transaction])
        render "user/transactions/edit"
      end
    end
  end

  def generate_items
    params.dig(:items, :file)&.map do |file|
      item = @transaction.items.new()
      item.process_file_upload = false
      item.assign_attributes(
        file: file
      )
      item if @transaction.delivery_form.name != "text"
    end
  end
  
  def remove_file
    @delivery_item = DeliveryItem.find(params[:id])
    @transaction = @delivery_item.deal
    if @delivery_item.delete
      redirect_to edit_user_transaction_path(@transaction.id), notice: 'ファイルを削除しました。'
    end
  end

  def deliver
    @transaction.set_delivery
    if @transaction.delivery_form.name != "text"
      @delivery_item = @transaction.items.first
    end

    if @transaction.save
      EmailJob.perform_later(mode: :deliver, model: @transaction) if @transaction.buyer.can_email_transaction
      create_notification(@transaction)
      flash.notice = "回答を納品しました。"
      path = @transaction.request.is_reward_mode? ? user_request_path(@transaction.request.id) : user_transaction_path(@transaction.id)
      redirect_to path
    else
      detect_models_errors([current_user, @transaction, @delivery_item])
      @transaction.is_transacted = false
      flash.notice = "回答を納品できませんでした。"
      render "user/orders/show"
    end
  end

  private def transaction_message_params
    params.require(:transaction_message).permit(
      :transaction_id,
      :body,
    )
  end

  def complete_delivery
    @transaction.save
    EmailJob.perform_later(mode: :deliver, model: @transaction) if @transaction.buyer.can_email_transaction
    create_notification(@transaction)
    flash.notice = "回答を納品しました。"
    redirect_to user_transaction_path(@transaction.id)
  end

  def like
    like = @transaction.likes.find_by(user: current_user)
    if like.present?
      like.destroy
    else
      @transaction.likes.create(user: current_user)
    end
  end

  def create_notification(transaction)
    Notification.create(
      user_id: transaction.buyer.id,
      notifier_id: current_user.id,
      title: "投稿した相談に回答が届きました",
      description: transaction.title,
      action: "show",
      controller: "transactions",
      id_number: transaction.id
      )
    current_user.followers.each do |user|
      Notification.create(
        user: user,
        notifier_id: current_user.id,
        title: '回答がされました',
        description: transaction.title,
        action: "show",
        controller: "transactions",
        id_number: transaction.id
        )
    end
  end

  def messages
    all_messages = @transaction.transaction_messages
      .after_request_published
    @total_message_count = all_messages.count
  end

  private def check_can_publish
    unless @transaction.can_publish
      flash.notice = transaction.errors_messages
      redirect_back(fallback_location: root_path)
    end
  end

  private def check_can_send_message
    if !@transaction.can_send_message(current_user)
      redirect_back(fallback_location: root_path)
    end
  end

  private def update_total_views
    @transaction.update(total_views:@transaction.total_views + 1)
  end
  
  private def can_edit_transaction
    if @transaction.is_canceled
      flash.notice = "取引は中断されています。"
      false
    elsif @transaction.is_rejected
      flash.notice = "取引は中断されています。"
      false
    elsif @transaction.is_transacted
      flash.notice = "既に取引が完了しています。"
      false
    else
      true
    end
  end

  private def define_transaction
    @transaction = Transaction.find(params[:id])
  end

  private def define_own_transaction
    @transaction = Transaction.find_by(id: params[:id], seller: current_user)
  end

  private def filter_transaction
    @transaction = Transaction.left_joins(:service)
    @transaction = @transaction.find_by(
      id: params[:id],
      service: {user: current_user},
      is_canceled: false,
      is_transacted: false,
      is_rejected: false,
      )
  end

  private def transaction_params
    params.require(:transaction).permit(
      :title,
      :description,
      :file,
      :thumbnail,
    )
  end

  private def transaction_item_params
    params.require(:transaction).permit(
      :file,
    )
  end

  private def check_transaction_published
    unless @transaction.is_published
      raise ActiveRecord::RecordNotFound
    end
  end

  private def check_transaction_not_published
    if @transaction.is_published
      raise ActiveRecord::RecordNotFound
    end
  end

  private def identify_seller
    transaction = Transaction.find(params[:id])
    if transaction.seller != current_user
      redirect_to new_user_session_path
    end
  end
end
