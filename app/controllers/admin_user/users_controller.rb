class AdminUser::UsersController < AdminUser::Base
  def index
    @users = User
      .where("users.name LIKE ?", "%#{params[:name]}%")
      .from_latest_order
      .page(params[:page])
      .per(50)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end
end
