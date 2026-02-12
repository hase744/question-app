class User::ChatMessagesController < User::Base
  before_action :check_login
  before_action :check_can_send_message
  def cells
    room = ChatRoom.find_by(id: params[:id])
    messages = room.messages
      .solve_n_plus_1
      .order(created_at: :desc)
      .page(params[:page])
      .per(15)
    render json: {
      messages: messages.map do |message|
        puts message.json(current_user)
        message.json(current_user)
      end,
      room_id: room.id
    }
  end

  def mark_as_read
    if messages = ChatMessage.where(receiver: current_user).where(id: params[:message_ids])
      messages.update_all(is_read: true)
      ChatMessagesChannel.broadcast_to(
        messages.first.sender,
        record_ids: params[:message_ids]
      )
    end
  end

  def create
    @message = ChatMessage.new(chat_message_params)
    @message.sender = current_user
    @room = @message.room
    @destination = @room.destinations.find_by(user: current_user)
    @receiver_destination = @room.destinations.find_by(@message.receiver)
    @message.receiver = @destination.target

    # 前回の相手のメッセージを取得
    last_message_from_receiver = @room.messages
      .where(sender: @message.receiver)
      .order(created_at: :desc)
      .first

    # response_timeを計算して設定（秒単位）
    if last_message_from_receiver
      @message.response_time = (Time.current - last_message_from_receiver.created_at).to_i
    end

    usable_transaction = @destination.usable_chat_transactions
    if usable_transaction && usable_transaction.first #送信可能な購入がある
      @message.chat_transaction = usable_transaction.first
    elsif current_user.can_send_message_as_seller_to?(@destination.target) #返信できる販売がある
      @message.chat_transaction = usable_transaction.first
    elsif @room.destinations.where.not(user: current_user)[0].chat_transactions.blank?
      render json: {
        success: false,
        errors: "DMプランを購入してください"
      }, status: :unprocessable_entity
      return
    end
    @room.is_valid = true
    @room.last_message_body = @message.body
    @room.last_message_at = DateTime.now
    @items = generate_items(@message)&.flatten
    @notification = new_notification(@message)
    ActiveRecord::Base.transaction do
      if save_models
        @message = ChatMessage.find(@message.id)
        message_json_with_class = @message.json(@message.receiver)
        message_json_with_class[:class_name] = @message.room.cell_class_name
        h = @message.json(@message.receiver)
        stream = "destination_#{@receiver_destination.id}"
        target = "destination_#{@receiver_destination.id}_messages"

        h[:images] = @message.items&.map do |item|
          render_to_string(
            partial: "user/chat_messages/image_component",
            locals: { item: item }
          ).to_s
        end.join('')

        Turbo::StreamsChannel.broadcast_append_to(
          stream,
          target: target,
          partial: "user/chat_messages/cell",
          locals: h
        )
        
        render json: {
          success: true,
          message: @message.json(current_user)
        }
      else
        render json: {
          success: false,
          errors: @message.errors_messages + @room.errors_messages
        }, status: :unprocessable_entity
      end
    end
  end

  def generate_items(message)
    return [] unless params.dig(:items, :file).present?
    params.dig(:items, :file)&.map do |file|
      item = @message.items.build
      item.process_file_upload = false
      item.file = file
      item 
    end
  end

  def new_notification(message)
    Notification.new(
      user: message.receiver,
      notifier_id: current_user.id,
      title: "メッセージが届きました",
      description: message.body,
      published_at: DateTime.now,
      action: "index",
      controller: "chat_destinations",
      id_number: nil,
      parameter: "?uuid=#{message.sender.uuid}"
      )
  end

  def chat_message_params
    params.require(:chat_message).permit(
      :body,
      :chat_room_id
    )
  end

  def chat_message_purchased
  end

  def check_can_send_message

  end
end
