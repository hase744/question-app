class Payout < ApplicationRecord
  belongs_to :user
  enum status_name: { paid: 0, pending: 1, in_transit: 2, canceled: 3, failed: 4 }

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
end
