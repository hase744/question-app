class Message < ApplicationRecord
    belongs_to :room
    belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"
    belongs_to :sender, class_name: "User", foreign_key: "sender_id"
    belongs_to :contact
    validate :validate_contact_room

    def validate_contact_room
        errors.add(:contact) if self.contact.room != self.room
    end
end
