class User::HomesController < ApplicationController
  layout "with_footer"
  def show
    @services = Service.all
      .solve_n_plus_1
      .where(request_id: nil)
      #.where.not(price: 0)
      .order(total_sales_numbers: :DESC)
      .order(Arel.sql('average_star_rating DESC NULLS LAST'))
      .limit(10)
    @users = User.all
      .solve_n_plus_1
      .where(is_seller:true)
      .order(total_sales_numbers: :DESC)
      .limit(10)
    @transactions = Transaction
      .solve_n_plus_1
      .delivered
      .order(total_views: :DESC)
      .limit(12)
  end
end
