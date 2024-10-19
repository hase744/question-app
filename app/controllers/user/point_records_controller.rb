class User::PointRecordsController < ApplicationController
  layout "small", only:[:show]
  def show
    @point_records = current_user.point_records
      .includes(:deal, :payment)
      .order(created_at: :desc)
      .page(params[:page]).per(50)
  end
end
