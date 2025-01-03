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
    if params[:uuid]&.include?('@')
      @target = User.find_by(uuid: params[:uuid])
      params[:uuid] = @target.id
    elsif params[:uuid]
      @target = User.find(params[:uuid])
    end
    @chat_destination = current_user.chat_destinations
      .find_by(target: @target) if @target
    @chat_destinations = current_user.chat_destinations.solve_n_plus_1
    if @chat_destination.present?
      @chat_destinations = @chat_destinations
        .select("chat_destinations.*, CASE WHEN id = #{ActiveRecord::Base.connection.quote(@chat_destination.id)} THEN 0 ELSE 1 END AS priority")
        .order("priority ASC")
    end
    @chat_destinations = @chat_destinations
      .page(params[:page])
      .per(10)
    return if params[:uuid].blank?
    if @chat_destination.blank?
      @chat_room = ChatRoom.new()
      @chat_room.destinations.build(
        user: current_user,
        target: @target,
        room: @chat_room
        )
      @chat_room.destinations.build(
        user: @target,
        target: current_user,
        room: @chat_room
        )
      if @chat_room.save
        @chat_destination = @chat_room.destinations
      end
      redirect_to user_chat_destinations_path()
    end
  end

  def show
  end
end
