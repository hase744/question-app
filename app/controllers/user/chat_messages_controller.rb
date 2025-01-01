class User::ChatMessagesController < User::Base
  before_action :check_login
  def cells
    #sleep 2
    room = ChatRoom.find_by(id: params[:id])
    messages = room.messages
      .order(created_at: :desc)
      .page(params[:page])
      .per(15)
      .reverse
    render "user/chat_messages/cells.js.erb", locals: {messages: messages, room: room}
  end

  def get_cells
  end

  def create
    message = ChatMessage.new(chat_message_params)
    message.sender = current_user
    message.receiver = message.room.destinations.find_by(user: current_user).target
    message.save
  end

  def chat_message_params
    params.require(:chat_message).permit(
      :body,
      :chat_room_id
    )
  end
end
