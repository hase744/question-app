class Review < ApplicationRecord
  belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id, dependent: :destroy
  validates :star_rating, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5}
  validates :body, length: {maximum: :body_max_length}, presence: true
  validates :transaction_id, uniqueness: { message: "この取引には既にレビューが存在します" }
  after_create :update_total_reviews
  before_validation :set_default_values
  attr_accessor :user

  def set_default_values
    if self.deal.is_published && self.deal.is_reward_mode?
      self.deal.price = self.reward
      self.deal.profit = self.reward*0.75
      self.deal.margin = self.reward*0.25
      self.deal.is_transacted = true
    end
  end

  def body_max_length
    500
  end

  after_initialize do
    if Rails.env.development?
      self.body ||= "ご助言いただき、ありがとうございます。自分の現状を見つめ直し、新しい挑戦を求める気持ちを具体的な行動に移すことの重要性を再認識しました。特に、興味や価値観を整理する時間を持つこと、スキルアップやネットワーキングに努めることが大切だと感じました。健康や生活の質にも注意を払いながら、将来を見据えて進んでいこうと思います。\nおかげさまで、今後のステップが少しずつ見えてきました。これからも前向きに取り組んでいきます。本当にありがとうございました。"
    end
  end

  def validate_user(user)
    unless self.deal.buyer == self.user
      errors.add(:user, "ユーザーが不適切です")
    end
  end

  def update_total_reviews
    self.deal.save
    self.deal.service.update(
      total_reviews: self.deal.service.reviews.count,
      average_star_rating: self.deal.service.reviews.average(:star_rating)
      )
    self.deal.seller.update(
      total_reviews: self.deal.seller.reviews.count,
      average_star_rating: self.deal.seller.reviews.average(:star_rating)
      )
  end
end
