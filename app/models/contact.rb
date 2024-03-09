class Contact < ApplicationRecord
    belongs_to :room
    belongs_to :user
    belongs_to :destination, class_name: "User", foreign_key: :destination_id
    #def room
    #    if self.room_id
    #    Room.find(self.room_id)
    #    end
    #end
end
