class ChatDestination < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy, class_name: "ChatMessage"
  belongs_to :target, class_name: 'User', foreign_key: :target_id
  belongs_to :room, class_name: 'ChatRoom', foreign_key: :chat_room_id
  validate :validate_target
  scope :solve_n_plus_1, -> {
    includes(:target, :room)
  }

  def validate_target
    if self.user == self.target
      errors.add(:target, "自分への宛先はできません")
    end
    if ChatDestination.exists?(user: self.user, target: self.target)
      errors.add(:target, "すでに宛先は存在しています")
    end
  end
end
