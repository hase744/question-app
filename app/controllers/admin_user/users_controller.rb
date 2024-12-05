class AdminUser::UsersController < AdminUser::Base
  def index
    @users = User
      .where("users.name LIKE ?", "%#{params[:name]}%")
    @users = @users.get_followees_of(User.find(params[:user_id])) if params[:target] == 'followees'
    @users = @users.get_followers_of(User.find(params[:user_id])) if params[:target] == 'followers'
    @users = @users.from_latest_order
      .page(params[:page])
      .per(50)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = user.find(params[:id])
    @user.assign_attributes(user_params)
		if @user.save
			flash.notice = "修正しました"
			redirect_to admin_user_user_path(@user.id)
    else
      render action: "edit"
    end
  end

  def user_params
    params.require(:user).permit(
      :state
    )
  end
end
