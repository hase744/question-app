class TransactionMessage < ApplicationRecord
  mount_uploader :file, ImageUploader
  store_in_background :file
  
  belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"

  validate :validate_sender
  validate :validate_can_send_message
  validate :validate_receiver
  #validates :body, length: {minimum: 1, maximum: :body_max_characters}
  attr_accessor :deadline
  before_validation :set_default_values

  scope :solve_n_plus_1, -> {
    includes(:sender, :receiver, :deal)
  }

  scope :sort_by_later, -> {
    order(created_at: :desc)
  }

  scope :after_transaction_published, -> {
    joins(:deal).where('transaction_messages.created_at > transactions.published_at')
  }

  scope :by_transaction_id_and_order, ->(params) {
    scope = includes(:sender)
    scope.where(transaction_id: params[:transaction_id])
      .order(created_at: params[:order])
      .page(params[:page])
      .per(5)
  }

  scope :before_transaction_published, -> (){
    joins(:deal).where('transaction_messages.created_at < transactions.published_at')
  }

  scope :after_published, -> (){
    joins(:deal).where('transaction_messages.created_at > transactions.published_at') 
  }

  scope :after_request_published, -> {
    joins(deal: :request).where('transaction_messages.published_at > requests.published_at')
  }

  def set_default_values
    @service = self.deal.service
    @request = self.deal.request
    @seller = @service.user
    @buyer = @request.user

    if new_record?
      self.published_at = DateTime.now
    end
  end

  def validate_can_send_message
    if message = self.deal.get_message_not_sendable_reason(self.sender)
      errors.add(:base, message)
    end
  end

  def body_with_link
    self.body.gsub(self.receiver.uuid, "<a href='/user/accounts/#{self.receiver.id}'>#{self.receiver.uuid}</a>")
  end

  def validate_sender
    return if self.deal.is_reward_mode?
    if self.sender != @buyer && self.sender != @seller
      errors.add(:sender, "送信者が不適切です")
    end
  end

  def validate_receiver
    return if is_receiver_valid?
    errors.add(:sender, "メッセージの宛先が不適切です") 
  end

  def is_receiver_valid?
    senders = self.deal.transaction_messages.solve_n_plus_1.map{|tm| tm.sender }
    return false if self.receiver == self.sender #宛先と送信者が同じな場合はエラー
    return true if self.deal.seller == self.receiver || self.deal.buyer == self.receiver
    return true if senders.include?(self.receiver) #取引のメッセージの送信者一覧に受信者がいる場合はOK
    false
  end

  def body_max_characters
    #1000
  end
end
