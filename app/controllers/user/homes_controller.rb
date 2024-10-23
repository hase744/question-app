class User::HomesController < ApplicationController
  layout "with_footer"
  def show
    @services = Service
      .solve_n_plus_1
      .where(request_id: nil)
      .sort_by_total_sales_numbers
      .sort_by_average_star_rating
      .limit(10)
    @users = User
      .solve_n_plus_1
      .where(is_seller:true)
      .limit(10)
    @transactions = Transaction
      .solve_n_plus_1
      .published
      .order(total_views: :DESC)
      .limit(12)
  end
end
