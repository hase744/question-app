class User::ReviewsController < User::Base
  before_action :check_login
  def create
    review = Review.new(review_params)
    review.user = current_user

    if review.save
      render partial: "user/reviews/success_response"
    else
      render partial: "user/reviews/failure_response"
    end
  end

  private def review_params
    params.require(:review).permit(
      :transaction_id,
      :star_rating,
      :body
    )
  end
end
