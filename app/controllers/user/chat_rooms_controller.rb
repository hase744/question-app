class User::ChatRoomsController < User::Base
  before_action :check_login
  def cells_modal
    room = ChatRoom.find_by(id: params[:id])
    render "user/chat_rooms/cells_modal.js.erb", locals: {room: room}
  end
end
