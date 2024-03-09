class User::ReviewsController < User::Base
  before_action :check_login
  def update
    transaction = Transaction.left_joins(:request).find_by(id:params[:id], request:{user: current_user}, reviewed_at: nil)

    if transaction.present?
      transaction.reviewed_at = DateTime.now
      transaction.assign_attributes(review_params)
      if transaction.save
        render partial: "user/reviews/success_response"
      else
        render partial: "user/reviews/failure_response"
      end
    else
      render partial: "user/reviews/failure_response"
    end
  end

  private def review_params
    params.require(:transaction).permit(
      :star_rating,
      :review_description
    )
  end
end
