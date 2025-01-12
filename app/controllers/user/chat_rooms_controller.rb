class User::ChatRoomsController < User::Base
  before_action :check_login
  def cells_modal
    room = ChatRoom.find_by(id: params[:id])
    render "user/chat_rooms/cells_modal.js.erb", locals: {room: room}
  end

  def is_creating
    room = ChatRoom.find(params[:id])
    receiver = room.destinations.find_by(user: current_user).target
    puts receiver.name
    ChatMessagesChannel.broadcast_to(
      receiver,
      creating_state: {
        is_creating: params[:is_creating] == 'true',
        room_class_name: room.cell_class_name
      }
    )
  end
end
