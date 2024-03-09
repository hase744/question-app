class Room < ApplicationRecord
    has_many :contacts, dependent: :destroy
    has_many :messages, dependent: :destroy
    def create_contacts(user,destination)
        Contact.create(room_id: self.id, user_id:user.id, destination_id:destination.id)
        Contact.create(room_id: self.id, user_id:destination.id, destination_id:user.id)
    end

    def contacts
        Contact.where(room_id: self.id)
    end
end
