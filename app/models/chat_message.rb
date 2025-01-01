class ChatMessage < ApplicationRecord
  belongs_to :sender, class_name: "User", dependent: :destroy, foreign_key: :sender_id
  belongs_to :receiver, class_name: "User", dependent: :destroy, foreign_key: :receiver_id
  belongs_to :receiver, class_name: "User", dependent: :destroy, foreign_key: :receiver_id
  belongs_to :room, class_name: "ChatRoom", dependent: :destroy, foreign_key: :chat_room_id
end