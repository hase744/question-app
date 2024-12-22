class User::BalanceRecordsController < User::Base
  before_action :check_login
  layout "small", only:[:show]
  def show
    @balance_records = current_user.balance_records
      .solve_n_plus_1
      .order(created_at: :desc)
      .page(params[:page]).per(50)
  end
end
