class User::RoomsController < User::Base
  def index
    @rooms = Room.where(user: current_user)
  end

  def show
    room = Room.find(params[:id])
    if room
      room.contact.each do |contact|
        if contact.user == current_user
          redirect_to user_contact_path(contact.id)
        end
      end
    else
      Room.create()
    end
  end

  def create
  end
end
