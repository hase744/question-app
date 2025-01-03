class ChatRoom < ApplicationRecord
  has_many :messages, dependent: :destroy, class_name: "ChatMessage"
  has_many :destinations, dependent: :destroy, class_name: "ChatDestination"
  accepts_nested_attributes_for :destinations, allow_destroy: true

  def cell_class_name
    "room_#{self.id}_cell"
  end
end
