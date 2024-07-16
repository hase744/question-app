class User::RequestLikesController < User::Base
  before_action :check_login, only:[:show, :create]
  layout 'medium_layout'
  def show
    @requests = Request
      .where(id: current_user.request_likes.pluck(:request_id))
      .page(params[:page])
      .per(20)
  end

  def create
    request = Request.find(params[:id])
    like = request.likes.find_by(user: current_user)
    if like.present?
      like.destroy
      render json: false
    else
      request.likes.create(user: current_user)
      render json: true
    end
  end
end
