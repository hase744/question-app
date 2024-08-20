class User::TransactionsController < User::Base
  #layout "search_layout", only: :index
  #layout "transaction_index", only: [:index]
  before_action :check_login, only:[:new, :create, :edit, :update, :create_description_image, :like, :messages]
  before_action :check_transaction_is_delivered, only:[:show, :like]
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
    gon.layout = "transaction_index"
    @transactions = Transaction.all
    @transactions = @transactions.joins(:transaction_categories)
    @transactions = @transactions.distinct
    @transactions = @transactions.solve_n_plus_1
    @transactions = @transactions.where(is_delivered:true).order(id: :DESC)
    @transactions = @transactions.filter_categories(params[:categories])
    @transactions = @transactions.where("title LIKE?", "%#{params[:word]}%")
    @transactions = @transactions.page(params[:page]).per(30)
  end

  def edit
    @transaction = Transaction.find(params[:id])
    if can_edit_transaction
      set_edit_values
    else
      redirect_to user_order_path(params[:id])
    end
    @transaction.items.build
  end

  def show
    if @transaction.request_form.name == "text"
      @og_image = @transaction.request.items.first.file.url
    elsif @transaction.service.item
      @og_image = @transaction.service.item&.file&.url
    end
    gon.env = Rails.env
    @transaction_along_messages =  TransactionMessage
      .joins(:deal)
      .where(transaction_id:@transaction.id)
      .where('transaction_messages.created_at < transactions.delivered_at')
    @total_message_count = TransactionMessage.where(transaction_id:@transaction.id).count
    gon.tweet_text = @transaction.description
    @transaction_message = TransactionMessage.new()

    #@transactionの前にアップロードされた取引と後にアップロードされた取引の数を比較し多い方をおすすめとして表示
    @transactions = Transaction.solve_n_plus_1
      .left_joins(:transaction_categories)
      .distinct
      .includes(:seller, :service, :request, :items, :transaction_categories)
      .where.not(id: @transaction.id)
      .where(
        is_delivered:true, 
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
    if !@transaction.is_delivered && params[:transaction][:file]
      @transaction.update(file: params[:transaction][:file])
    end
  end

  def update
    @transaction.assign_attributes(transaction_params)
    @transaction.category.name
    @items = generate_items&.flatten
    @transaction.transaction_categories.build(category_name:"business")
    ActiveRecord::Base.transaction do
      if save_models
        flash.notice = "回答を編集しました"
        redirect_to user_order_path(params[:id])
      else
        delete_temp_file_items
        detect_models_errors([@transaction.item, @transaction])
        set_edit_values
        render "user/transactions/edit"
      end
    end
  end

  def generate_items
    params.dig(:items, :file)&.map do |file|
      item = @transaction.items.new()
      item.process_file_upload = true
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
    @transaction.assign_attributes(deliver_params)
    @transaction.delivered_at = DateTime.now

    if @transaction.delivery_form.name != "text"
      @delivery_item = @transaction.items.first
    end
    
    if all_models_valid?([current_user, @transaction, @delivery_item])
      if @transaction.profit > 0
        transfer = Stripe::Transfer.create(
              amount: @transaction.profit,
              currency: 'jpy',
              destination: @transaction.seller.stripe_account_id
        )
        if !transfer.reversed
          @transaction.stripe_transfer_id = transfer.id
          complete_delivery
        else
          flash.notice = "回答を納品できませんでした。"
          redirect_to user_order_path(params[:id])
        end
      else
        complete_delivery
      end
    else
      detect_models_errors([current_user, @transaction, @delivery_item])
      @transaction.is_delivered = false
      flash.notice = "回答を納品できませんでした。"
      render "user/orders/show"
    end
  end

  def complete_delivery
    @transaction.save
    EmailJob.perform_later(mode: :deliver, model: @transaction)
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
    transaction.update_total_likes
  end

  def create_notification(transaction)
    Notification.create(
      user_id: transaction.buyer.id,
      notifier_id: current_user.id,
      description: "あなたの依頼した相談に回答が納品されました。",
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
    elsif @transaction.is_delivered
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
      is_delivered: false,
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

  private def set_edit_values
    gon.delivery_form = @transaction.service.delivery_form.name
  end

  private def transaction_item_params
    params.require(:transaction).permit(
      :file,
      :use_youtube,
      :youtube_id,
    )
  end

  private def deliver_params
    params.require(:transaction).permit(
      :is_delivered
    )
  end

  private def check_transaction_is_delivered
    if  !Transaction.exists?(id:params[:id], is_delivered:true)
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
