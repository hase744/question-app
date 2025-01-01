class User::ChatDestinationsController < User::Base
  before_action :check_login
  layout :choose_layout

  private def choose_layout
    case action_name
    when "index"
      "small"
    end
  end

  def index
    @chat_destinations = current_user.chat_destinations
      .page(params[:page]).per(10)
    return if params[:uuid].blank?
    @target = User.find(params[:uuid])
    @chat_destination = @chat_destinations.find_by(target: @target)
    if @chat_destination.blank?
      @chat_room = ChatRoom.new()
      @chat_room.chat_destinations.build(
        user: current_user,
        target: @target,
        room: @chat_room
        )
      @chat_room.chat_destinations.build(
        user: @target,
        target: current_user,
        room: @chat_room
        )
      if @chat_room.save!
        @chat_destination = @chat_room.chat_destinations
      end
      redirect_to user_chat_destination_path()
    end
  end

  def show
  end
end
