class AdminUser::BalanceRecordsController < AdminUser::Base
  def index
    @balance_records = BalanceRecord.all
    @balance_records = @balance_records.where(user_id: params[:user_id]) if params[:user_id]
    @balance_records = @balance_records
      .from_latest_order
      .page(params[:page])
      .per(50)
  end

  def show
    @balance_record = BalanceRecord.find(params[:id])
  end
end
