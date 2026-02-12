class ChatMessage < ApplicationRecord
  belongs_to :sender, class_name: "User", dependent: :destroy, foreign_key: :sender_id
  belongs_to :receiver, class_name: "User", dependent: :destroy, foreign_key: :receiver_id
  belongs_to :room, class_name: "ChatRoom", dependent: :destroy, foreign_key: :chat_room_id
  belongs_to :chat_transaction, class_name: "ChatTransaction", dependent: :destroy, foreign_key: :chat_transaction_id, optional: true
  has_many :items, class_name: "ChatMessageItem", dependent: :destroy
  validates :body, presence: { message: 'メッセージの入力が必要です'}
  accepts_nested_attributes_for :items, allow_destroy: true

  scope :solve_n_plus_1, -> {
    includes(:sender, :receiver, :room, :items)
  }

  def is_read_status(user)
    user == self.sender ? (self.is_read ? '既読' : '未読') : ''
  end

  def cell_class_name
    "message_cell_#{self.id}"
  end

  def json(user)
    {
      id: self.id,
      image_url: self.sender.thumb_with_default,
      side: self.sender == user ? 'right' : 'left',
      body: self.body,
      created_at: self.created_at,
      created_at_display: self.created_at.strftime("%H:%M"),
      readable_created_at: readable_datetime(self.created_at),
      is_read_status: self.is_read_status(user),
      is_read: self.is_read,
      image_length: self.items.count,
      record_id: '',
      date: 'undefined',
      images: self.items.map{|item| {
        url: item.thumb_file_with_default,
        link: item.normal_file_with_default,
        class_name: item.image_thumb_style_class
        } }
    }
  end
end