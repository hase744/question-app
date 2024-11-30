class PointRecord < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :payment, optional: true
  belongs_to :deal, class_name: 'Transaction', optional: true, foreign_key: :transaction_id
  enum type_name: { charge: 0, refund: 1, contract: 2, cancel: 3, rejection: 4 , violation: 5} #rejectは"reject", which is already defined by ActiveRecord::Relation.
  def type_name_japanese
    {'charge'=> 'チャージ', 'refund'=> '返金', 'contract'=> '購入', 'cancel'=> 'キャンセル', 'rejection'=> 'お断り', 'violation'=> '取引無効による払い戻し'}[self.type_name]
  end

  def image_path
    if self.transaction_id
      self.deal.request.thumb_with_default
    elsif self.payment_id
      "/wallet-300x300.jpg"
    else
      "/favicon.ico"
    end
  end
end