class User::ChatRoomsController < User::Base
  before_action :check_login
  def cells_modal
    room = ChatRoom.find_by(id: params[:id])
    render "user/chat_rooms/cells_modal.js.erb", locals: {room: room}
  end

  def is_creating
    room = ChatRoom.find(params[:id])
    receiver = room.destinations.find_by(user: current_user).target
    receiver_destination = room.destinations.where.not(user: current_user).first
    stream = "destination_#{receiver_destination.id}"
    show = ActiveModel::Type::Boolean.new.cast(params[:is_creating])

    html = ApplicationController.render(
      partial: "user/chat_messages/creating_state_wrapper",
      locals: { destination: receiver_destination, show: show }
    )

    begin
    Turbo::StreamsChannel.broadcast_action_to(
      stream,
      action: :replace,
      target: "creating_state_#{receiver_destination.id}",
      html: html
    )
    rescue => e
      puts "エラー"
      puts e
    end
    #ChatMessagesChannel.broadcast_to(
    #  receiver,
    #  creating_state: {
    #    is_creating: params[:is_creating] == 'true',
    #    room_class_name: room.cell_class_name
    #  }
    #)
  end
end
