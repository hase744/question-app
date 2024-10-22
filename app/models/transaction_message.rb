class TransactionMessage < ApplicationRecord
  mount_uploader :file, ImageUploader
  store_in_background :file
  
  belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"

  validate :validate_sender
  validate :can_send_message
  #validates :body, length: {minimum: 1, maximum: :body_max_characters}
  attr_accessor :deadline
  before_validation :set_default_values

  scope :solve_n_plus_1, -> {
    includes(:sender, :receiver, :deal)
  }

  scope :by_transaction_id_and_order, ->(params) {
    scope = includes(:sender).joins(:deal)
    scope = scope.where('transaction_messages.created_at > transactions.published_at') if params[:after_delivered]
    scope.where(transaction_id: params[:transaction_id])
      .order(created_at: params[:order])
      .page(params[:page])
      .per(5)
  }

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

  def can_send_message
    if !self.deal.can_send_message(self.sender)
      errors.add(:deadline, "メッセージを送信できません")
    end
  end

  def validate_sender
    if self.sender != @buyer && self.sender != @seller
      errors.add(:sendr, "が不適切です")
    end
  end

  def body_max_characters
    #1000
  end
end
