class ChatMessage < ApplicationRecord
  belongs_to :sender, class_name: "User", dependent: :destroy, foreign_key: :sender_id
  belongs_to :receiver, class_name: "User", dependent: :destroy, foreign_key: :receiver_id
  belongs_to :room, class_name: "ChatRoom", dependent: :destroy, foreign_key: :chat_room_id
  validates :body, presence: { message: 'メッセージの入力が必要です'}

  scope :solve_n_plus_1, -> {
    includes(:sender, :receiver, :room)
  }

  def is_read_status(user)
    user == self.sender ? (self.is_read ? '既読' : '未読') : ''
  end
end