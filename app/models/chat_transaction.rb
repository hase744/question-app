class ChatTransaction < ApplicationRecord
  belongs_to :buyer, class_name: "User", foreign_key: :buyer_id
  belongs_to :chat_service
  belongs_to :chat_destination
  delegate :user, to: :chat_service, prefix: :seller
  has_many :coupon_usages, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  has_many :coupons, through: :coupon_usages, dependent: :destroy
  has_many :point_records, dependent: :destroy
  has_many :balance_records, dependent: :destroy

  enum type_name: {
    one_time: 0,
    one_week: 1,
    one_month: 2,
  }

  enum state: {
    transacted: 0,
    canceled: 1,
  }

  before_validation :set_default_value
  after_save :create_payment_record

  # 購入された側は無制限に返信できるような機能
  scope :sendable_as_seller_by, ->(sender:, receiver:) {
    joins(:chat_service)
      .where(state: :transacted)
      .where(buyer_id: sender.id)
      .where(chat_services: { user_id: receiver.id })
  }

  def remaining_count
    return nil unless one_time?

    remaining = count - chat_messages.count
    [remaining, 0].max
  end

  def started_at
    chat_messages.minimum(:created_at)
  end

  def expires_at
    return nil if started_at.nil?

    case type_name
    when "one_week"
      started_at + count.weeks
    when "one_month"
      # 現状のusable条件が interval '30 day' * count なので、それに合わせる
      started_at + (30 * count).days
      # もし「暦の1ヶ月」を使いたいなら: started_at + count.months
    else
      nil
    end
  end

  def remaining_seconds(now = Time.current)
    return nil if expires_at.nil?
    [expires_at - now, 0].max
  end

  def scope
    self.type_name == 'one_week' ? 1.week : 30.days
  end

  scope :usable, -> {
    left_outer_joins(:chat_messages).group('chat_transactions.id').having(
      <<~SQL
      (
        (chat_transactions.type_name = 0 AND COUNT(chat_messages.id) < chat_transactions.count)
        OR
        (chat_transactions.type_name = 1 AND (
          (chat_transactions.limit IS NULL OR COUNT(chat_messages.id) <= chat_transactions.limit)
          AND (
            NOT EXISTS (SELECT 1 FROM chat_messages WHERE chat_messages.chat_transaction_id = chat_transactions.id)
            OR
            (SELECT MIN(chat_messages.created_at) FROM chat_messages WHERE chat_messages.chat_transaction_id = chat_transactions.id) + (interval '1 week' * chat_transactions.count) > NOW()
          )
        ))
        OR
        (chat_transactions.type_name = 2 AND (
          (chat_transactions.limit IS NULL OR COUNT(chat_messages.id) <= chat_transactions.limit)
          AND (
            NOT EXISTS (SELECT 1 FROM chat_messages WHERE chat_messages.chat_transaction_id = chat_transactions.id)
            OR
            (SELECT MIN(chat_messages.created_at) FROM chat_messages WHERE chat_messages.chat_transaction_id = chat_transactions.id) + (interval '30 day' * chat_transactions.count) > NOW()
          )
        ))
      )
    SQL
    )
  }

  def seller
    self.chat_service.user
  end

  def coupon_user
    self.buyer
  end

  def total_price
    self.count * self.price
  end

  def set_default_value
    copy_chat_service
  end

  def copy_chat_service
    if self.chat_service
      self.type_name = self.chat_service.type_name
      self.price = self.chat_service.price
      self.limit = self.chat_service.limit
      self.profit = self.chat_service.price*0.75
      self.fee = self.chat_service.price*0.25
    end
  end

  def self.selector_hash
    I18n.t('activerecord.attributes.chat_service/type_name').invert
  end

  def type_name_japanese
    I18n.t("activerecord.attributes.chat_service/type_name.#{type_name}")
  end

  def create_payment_record
    #return if saved_change_to_id? #新規のデータの時、return
    discounted_price = self.price - self.coupon_usages.sum(:amount)
    if self.state == 'transacted' && discounted_price > 0
      self.point_records.create(
        user: self.buyer,
        chat_transaction: self,
        amount: -discounted_price,
        type_name: 'chat_transaction',
        created_at: self.updated_at,
      )
    end
    if self.state == 'transacted' && self.profit > 0
      self.balance_records.create(
        user: self.chat_service.user,
        amount: self.profit,
        type_name: 'chat_transaction',
        created_at: self.updated_at,
      )
    end
  end
end