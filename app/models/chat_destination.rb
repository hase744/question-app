class ChatDestination < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy, class_name: "ChatMessage"
  belongs_to :target, class_name: 'User', foreign_key: :target_id
  belongs_to :room, class_name: 'ChatRoom', foreign_key: :chat_room_id
end
