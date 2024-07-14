class User::ServiceLikesController < User::Base
  before_action :check_login, only:[:show, :create]
  layout 'small'
  def show
    @services = Service
    .where(id: current_user.service_likes.pluck(:service_id))
    .page(params[:page])
    .per(20)
  end

  def create
    service = Service.find(params[:id])
    like = service.likes.find_by(user: current_user)
    if like.present?
      like.destroy
      render json: false
    else
      service.likes.create(user: current_user)
      render json: true
    end
  end
end
