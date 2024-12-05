class AdminUser::ErrorLogsController < AdminUser::Base
  def index
    @error_logs = ErrorLog.all
    @error_logs = @error_logs.where(user_id: params[:user_id]) if params[:user_id]
    @error_logs = @error_logs.where(uuid: params[:uuid]) if params[:uuid]
    @error_logs = @error_logs 
      .from_latest_order
      .page(params[:page])
      .per(50)
  end

  def show
    @error_log = ErrorLog.find(params[:id])
  end
end
