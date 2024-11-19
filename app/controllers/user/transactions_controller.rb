class User::TransactionsController < User::Base
  #layout "search_layout", only: :index
  #layout "transaction_index", only: [:index]
  before_action :check_login, only:[:new, :create, :edit, :update, :create_description_image, :like, :messages]
  before_action :check_transaction_is_transacted, only:[:show, :like]
  before_action :define_transaction, only:[:show, :update, :deliver, :messages]
  before_action :filter_transaction, only:[:update, :deliver]
  before_action :define_transaction_message, only:[:show, :messages]
  before_action :identify_seller, only:[:edit, :update, :create_description_image]
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
    @transactions = Transaction.all
    @transactions = @transactions.joins(:transaction_categories)
    @transactions = @transactions.distinct
    @transactions = @transactions.solve_n_plus_1
    @transactions = @transactions.where(is_published:true)
    @transactions = @transactions.filter_categories(params[:categories])
    @transactions = @transactions.where("transactions.title LIKE ?", "%#{params[:word]}%") if params[:word].present?
    @transactions = @transactions.page(params[:page]).per(30)
    @transactions = @transactions.sorted_by(params[:order])
  end

  def edit
    @transaction = Transaction.find(params[:id])
    unless can_edit_transaction
      redirect_to user_order_path(params[:id])
    end
    @transaction.items.build
  end

  def show
    $og_image = @transaction.request.items.first.file.url if @transaction.request.items.select{|item| item.file.is_image?}.present?
    @transaction_along_messages =  TransactionMessage
      .joins(:deal)
      .where(transaction_id:@transaction.id)
      .where('transaction_messages.created_at < transactions.published_at')
      .where('transaction_messages.created_at > transactions.contracted_at')
    @total_message_count = TransactionMessage.where(transaction_id:@transaction.id).count
    @tweet_text = @transaction.description
    @transaction_message = TransactionMessage.new()

    #@transactionの前にアップロードされた取引と後にアップロードされた取引の数を比較し多い方をおすすめとして表示
    @transactions = Transaction.solve_n_plus_1
      .left_joins(:transaction_categories)
      .distinct
      .includes(:seller, :service, :request, :items, :transaction_categories)
      .where.not(id: @transaction.id)
      .where(
        is_published:true, 
        transaction_categories:{category_name: @transaction.category.name}
        )
    @total_message_count = @transaction.total_after_delivered_messages
    transactions = @transactions.where(id: ..@transaction.id).order(created_at: "ASC").limit(10)
    @transactions = @transactions.where(id: @transaction.id..).order(created_at: "ASC").limit(10)
    if @transactions.count < transactions.count
      @transactions = transactions
    end
    transaction_like = TransactionLike.find_by(user:current_user, transaction_id: params[:id])
    if transaction_like
      @transaction_like_exist = true
    end
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
        redirect_to user_order_path(params[:id])
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
      redirect_to user_transaction_path(@transaction.id)
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
    transaction = Transaction.find(params[:id])
    like = transaction.likes.find_by(user: current_user)
    if like.present?
      like.destroy
    else
      transaction.likes.create(user: current_user)
    end
  end

  def create_notification(transaction)
    Notification.create(
      user_id: transaction.buyer.id,
      notifier_id: current_user.id,
      title: "あなたの依頼した相談に回答が納品されました",
      description: transaction.title,
      action: "show",
      controller: "transactions",
      id_number: transaction.id
      )
  end

  def new_image(name)
    @text = @transaction.description
    erb = File.read('./app/views/user/images/answer.html.erb')
    kit = IMGKit.new(ERB.new(erb).result(binding))
    img = kit.to_img(:jpg)
    kit.to_file("./app/assets/images/#{name}.png")
  end

  def messages
    @total_message_count = TransactionMessage.where(transaction_id:@transaction.id).count
  end

  private def check_can_send_message
    if !@transaction.can_send_message(current_user)
      redirect_back(fallback_location: root_path)
    end
  end

  private def update_total_views
    @transaction.update(total_views:@transaction.total_views + 1, item:nil)
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

  private def define_transaction_message
    params[:transaction_message_order] ||= "ASC"
    @transaction_messages = TransactionMessage
      .by_transaction_id_and_order(
        transaction_id: params[:id], 
        order: params[:transaction_message_order],
        page: 1,
        after_delivered: action_name == "show"
      )
  end

  private def transaction_params
    params.require(:transaction).permit(
      :title,
      :description,
      :file,
      :thumbnail,
      :use_youtube,
      :youtube_id,
    )
  end

  private def transaction_item_params
    params.require(:transaction).permit(
      :file,
      :use_youtube,
      :youtube_id,
    )
  end

  private def check_transaction_is_transacted
    if  !Transaction.exists?(id:params[:id], is_transacted:true)
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
