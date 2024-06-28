class User::TransactionsController < User::Base
  #layout "search_layout", only: :index
  #layout "transaction_index", only: [:index]
  before_action :check_login, only:[:new, :create, :edit, :update, :create_description_image, :like]
  before_action :check_transaction_is_delivered, only:[:show, :like]
  before_action :define_transaction, only:[:update, :deliver]
  before_action :identify_seller, only:[:edit, :update, :create_description_image]
  after_action :update_total_views, only:[:show]
  layout :choose_layout

  private def choose_layout
    case action_name
    when "show"
      "responsive_layout"
    when "index"
      "search_layout"
    else
      "small"
    end
  end

  def index
    gon.layout = "transaction_index"
    @transactions = Transaction.left_joins(:transaction_categories)
    @transactions = solve_n_plus_1(@transactions)
    @transactions = @transactions.where(is_delivered:true).order(id: :DESC)
    @transactions = @transactions.filter_categories(params)
    @transactions = @transactions.where("title LIKE?", "%#{params[:word]}%")
    @transactions = @transactions.page(params[:page]).per(30)
    @transactions.each do |t|
      t.set_item
    end
    
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
    @transaction = Transaction.find(params[:id])
    @transaction.set_item
    @transaction.request.set_item_values
    if @transaction.file && @transaction.file.url
      if @transaction.request_form.name == "text"
        @transaction.request.set_item_values
        @og_image = @transaction.request.file.url
      elsif @transaction.service.image
        @og_image = @transaction.service.image.url
      end
      gon.env = Rails.env
    end
    gon.tweet_text = @transaction.description

    if params[:transaction_message_order]
      begin #params[:transaction_message_order]がs"ASC"でも"SESC"でもないとき
        @transaction_messages = TransactionMessage.includes(:sender).where(transaction_id:params[:id]).order(created_at:params[:transaction_message_order]).limit(5)
      rescue
        flash.notice = "orderが無効です。"
        @transaction_messages = TransactionMessage.includes(:sender).where(transaction_id:params[:id]).limit(5)
      end
    else
      @transaction_messages = TransactionMessage.includes(:sender).where(transaction_id:params[:id]).limit(5)
    end
    gon.total_transaction_messages = TransactionMessage.where(transaction_id:@transaction.id).count
    gon.text_max_length = TransactionMessage.new.body_max_characters

    @transaction_message = TransactionMessage.new()

    #@transactionの前にアップロードされた取引と後にアップロードされた取引の数を比較し多い方をおすすめとして表示
    #@transactions = solve_n_plus_1(@transactions)
    @transactions = Transaction.left_joins(:transaction_categories).includes(:seller, :service, :request, :items, :categories).where(is_delivered:true, transaction_categories:{category: @transaction.category})
    transactions = @transactions.where(id: ..@transaction.id).order(created_at: "ASC").limit(10)
    @transactions = @transactions.where(id: @transaction.id..).order(created_at: "ASC").limit(10)
    if @transactions.count < transactions.count
      @transactions = transactions
    end
    @transactions.each do |t|
      t.set_item
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
    if  @transaction.save#save_transaction_and_items
      params.dig(:items, :file).each do |file|
        @transaction.items.create(file: file)
      end
      flash.notice = "回答を編集しました"
      redirect_to user_order_path(params[:id])
    else
      detect_models_errors([@transaction.item, @transaction])
      set_edit_values
      render "user/transactions/edit"
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
      transfer = Stripe::Transfer.create(
            amount: @transaction.profit,
            currency: 'jpy',
            destination: @transaction.seller.stripe_account_id
      )
      if !transfer.reversed
        @transaction.stripe_transfer_id = transfer.id
        @transaction.save
        Email::TransactionMailer.delivery(@transaction).deliver_now
        create_notification(@transaction)
        flash.notice = "回答を納品しました。"
        redirect_to user_transaction_path(@transaction.id)
      else
        flash.notice = "回答を納品できませんでした。"
        redirect_to user_order_path(params[:id])
      end
    else
      detect_models_errors([current_user, @transaction, @delivery_item])
      @transaction.is_delivered = false
      flash.notice = "回答を納品できませんでした。"
      render "user/orders/show"
    end
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

  def set_values_in_show
    @transaction = Transaction.find(params[:id])
    if @transaction.file.url
      if @transaction.request_form.name == "text"
        @og_image = @transaction.request.file.url
      elsif @transaction.service.image
        @og_image = @transaction.service.image.url
      end
      gon.env = Rails.env
    end
    gon.tweet_text = @transaction.description

    if params[:transaction_message_order]
      begin #params[:transaction_message_order]がs"ASC"でも"SESC"でもないとき
        @transaction_messages = TransactionMessage.includes(:sender).where(transaction_id:params[:id]).order(created_at:params[:transaction_message_order]).limit(5)
      rescue
        flash.notice = "orderが無効です。"
        @transaction_messages = TransactionMessage.includes(:sender).where(transaction_id:params[:id]).limit(5)
      end
    else
      @transaction_messages = TransactionMessage.includes(:sender).where(transaction_id:params[:id]).limit(5)
    end
    gon.total_transaction_messages = TransactionMessage.where(transaction_id:@transaction.id).count

    @transaction_message = TransactionMessage.new()

    #@transactionの前にアップロードされた取引と後にアップロードされた取引の数を比較し多い方をおすすめとして表示
    @transactions = Transaction.left_joins(:transaction_categories).includes(:seller, :request).where(is_delivered:true, transaction_categories:{category: @transaction.category})
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

  def new_image(name)
    @text = @transaction.description
    erb = File.read('./app/views/user/images/answer.html.erb')
    kit = IMGKit.new(ERB.new(erb).result(binding))
    img = kit.to_img(:jpg)
    kit.to_file("./app/assets/images/#{name}.png")
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
    @transaction = Transaction.left_joins(:service)
    @transaction = @transaction.find_by(
      id: params[:id],
      service: {user: current_user},
      is_canceled: false,
      is_delivered: false,
      is_rejected: false,
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
    gon.text_max_length = @transaction.description_max_length
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
