class User::HomesController < User::Base
  layout "with_footer"
  before_action :detect_state
  def show
    @services = Service
      .solve_n_plus_1
      .seeable
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

  def detect_state
    redirect_to abouts_path  if current_state != 'running'
  end
end
