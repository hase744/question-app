class User::ChatMessagesController < User::Base
  before_action :check_login
  def cells
    params[:page] = params[:page].to_i
    room = ChatRoom.find_by(id: params[:id])
    messages = room.messages
      .solve_n_plus_1
      .order(created_at: :desc)
      .page(params[:page])
      .per(15)
    render json: {
      messages: messages.map do |message|
        message.json(current_user)
      end,
      room_id: room.id
    }
  end

  def mark_as_read
    if messages = ChatMessage.where(receiver: current_user).where(id: params[:message_ids])
      messages.update_all(is_read: true)
    end
  end

  def create
    @message = ChatMessage.new(chat_message_params)
    @message.sender = current_user
    @message.receiver = @message.room.destinations.find_by(user: current_user).target
    @room = @message.room
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
        ChatMessagesChannel.broadcast_to(
          @message.receiver,
          message: message_json_with_class
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
end
