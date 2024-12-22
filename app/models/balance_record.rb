class BalanceRecord < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :payout, optional: true
  belongs_to :deal, class_name: 'Transaction', optional: true, foreign_key: :transaction_id
  enum type_name: { deal: 0, payout: 1, fee: 2, violation: 3}

  scope :solve_n_plus_1, -> {
    includes(:user, :payout, :deal, { deal: { request: :items} })
  }

  def type_name_japanese
    {'deal'=> '回答報酬', 'payout'=> '入金', 'violation'=> '取引無効による収益の返還'}[self.type_name]
  end

  def image_path
    if self.transaction_id
      self.deal.request.items.first.file.thumb.url
    elsif self.payout_id
      "/passbook-300x300.jpg"
    else
      "/favicon.ico"
    end
  end
end
