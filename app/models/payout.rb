class Payout < ApplicationRecord
  belongs_to :user
  has_many :balance_records
  enum status_name: { paid: 0, pending: 1, in_transit: 2, canceled: 3, failed: 4 }
  after_save :create_record

  def status_japanese
    case self.status_name
    when "paid"
      "完了"
    when "pending"
      "準備中"
    when "in_transit"
      "送金中"
    when "canceled"
      "キャンセル"
    when "failed"
      "失敗"
    end
  end

  def create_record
    return unless saved_change_to_id?
    balance_records.create(
      user: self.user,
      payout: self,
      amount: -self.amount,
      type_name: 'payout',
      created_at: self.update_at
    )
    balance_records.create(
      user: self.user,
      payout: self,
      amount: -200,
      type_name: 'fee',
      created_at: self.update_at,
    )
  end
end
