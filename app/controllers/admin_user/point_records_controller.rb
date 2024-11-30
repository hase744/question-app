class AdminUser::PointRecordsController < AdminUser::Base
  def index
    @point_records = PointRecord.all
    @point_records = @point_records.where(user_id: params[:user_id]) if params[:user_id]
    @point_records = @point_records
      .from_latest_order
      .page(params[:page])
      .per(50)
  end

  def show
    @point_records = PointRecord.find(params[:id])
  end
end
