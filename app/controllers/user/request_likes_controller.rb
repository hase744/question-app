class User::RequestLikesController < User::Base
  before_action :check_login, only:[:show, :create]
  layout 'medium_layout'
  def show
    @requests = Request.joins(:likes)
      .solve_n_plus_1
      .where(likes: { user_id: current_user.id })
      .order('likes.created_at DESC')
      .page(params[:page])
      .per(20)
  end

  def create
    request = Request.find(params[:id])
    return if !request.is_published
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
