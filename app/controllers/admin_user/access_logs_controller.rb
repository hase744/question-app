class AdminUser::AccessLogsController < AdminUser::Base
  def index
    @access_logs = AccessLog.all
    @access_logs = @access_logs.where(user_id: params[:user_id]) if params[:user_id]
    @access_logs = @access_logs 
      .from_latest_order
      .page(params[:page])
      .per(50)
  end

  def show
    @access_log = AccessLog.find(params[:id])
  end
end
