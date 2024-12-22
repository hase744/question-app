class User::PointRecordsController < ApplicationController
  layout "small", only:[:show]
  def show
    @point_records = current_user.point_records
      .solve_n_plus_1
      .order(created_at: :desc)
      .page(params[:page]).per(50)
  end
end
