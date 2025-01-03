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
        {
          id: message.id,
          image_url: message.sender.thumb_with_default,
          side: message.sender == current_user ? 'right' : 'left',
          body: message.body,
          created_at: message.created_at,
          created_at_display: message.created_at.strftime("%H:%M"),
          is_read_status: message.is_read_status(current_user),
          is_read: message.is_read
        }
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
    return if params[:commit] == ""
    message = ChatMessage.new(chat_message_params)
    message.sender = current_user
    message.receiver = message.room.destinations.find_by(user: current_user).target
    room = message.room
    room.last_message_body = message.body
    room.last_message_at = DateTime.now
    notification = new_notification(message)
    ActiveRecord::Base.transaction do
      if message.save && room.save && notification.save
        render json: {
          success: true,
          message: {
            id: message.id,
            image_url: message.sender.image_url, # 適切に設定
            side: message.sender == current_user ? 'right' : 'left',
            body: message.body,
            created_at: message.created_at,
            created_at_display: message.created_at.strftime("%H:%M"),
            is_read_status: message.is_read_status(current_user),
            is_read: message.is_read
          }
        }
      else
        render json: {
          success: false,
          errors: message.errors_messages + room.errors_messages
        }, status: :unprocessable_entity
      end
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
