class User::BalanceRecordsController < ApplicationController
  layout "small", only:[:show]
  def show
    @balance_records = current_user.balance_records
      .includes(:deal, :payout)
      .order(created_at: :desc)
      .page(params[:page]).per(50)
  end
end
