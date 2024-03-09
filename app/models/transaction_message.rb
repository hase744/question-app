class TransactionMessage < ApplicationRecord
  mount_uploader :file, FileUploader
  
  belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"

  validate :validate_transaction_is_delivered
  validate :validate_sender
  validate :validate_deadline
  validates :body, length: {minimum: 1, maximum: :body_max_characters}
  attr_accessor :deadline
  
  before_validation :set_default_values

  def set_default_values
    @service = self.deal.service
    @request = self.deal.request
    @seller = @service.user
    @buyer = @request.user
    if will_save_change_to_sender_id?
      case self.sender
      when @seller then
        self.receiver = @buyer
      when @buyer then
        self.receiver = @seller
      end
    end
  end

  def validate_deadline
    if self.sender == @buyer && (self.deal.delivered_at + self.deal.transaction_message_days) > DateTime.now
      errors.add(:deadline, "が過ぎています")
    end
  end
  
  def validate_sender
    if self.sender != @buyer && self.sender != @seller
      errors.add(:sendr, "が不適切です")
    end
  end

  def validate_transaction_is_delivered
    errors.add(:deal, "の納品が完了していません") if !self.deal.is_delivered
  end

  def body_max_characters
    1000
  end
end
