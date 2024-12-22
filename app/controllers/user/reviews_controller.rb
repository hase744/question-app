class User::ReviewsController < User::Base
  before_action :check_login
  def create
    review = Review.new(review_params)
    review.reward = review.reward.to_i
    review.user = current_user

    ActiveRecord::Base.transaction do
      if review.valid? && review.deal.valid? && review.save
        flash.notice = 'レビューを投稿しました'
        Notification.create(
          user: review.deal.seller,
          notifier_id: current_user.id,
          controller: "transactions",
          action: 'show',
          id_number: review.deal.id,
          title: '回答にレビューがされました。',
          description: review.body,
          parameter: nil
        )
      else
        errors = review.errors.full_messages + review.deal.errors.full_messages
        flash.alert = errors.join("\n")
        raise ActiveRecord::Rollback # トランザクションをロールバック
      end
    end

    redirect_back(fallback_location: root_path)
  end

  private def review_params
    params.require(:review).permit(
      :transaction_id,
      :star_rating,
      :reward,
      :body
    )
  end
end
