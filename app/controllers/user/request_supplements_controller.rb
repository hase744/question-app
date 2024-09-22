class User::RequestSupplementsController < User::Base
  before_action :check_login
  before_action :define_request
  before_action :check_request_is_suppliable
  layout 'small'

  def new
    @request_supplement = RequestSupplement.new
  end

  def create
    @request_supplement = RequestSupplement.new(request_supplement_params)
    if @request_supplement.save
      flash.notice = "補足を作成しました。"
      redirect_to user_request_path(@request.id)
    else
      flash.notice = "補足の作成に失敗しました。"
      render "user/request_supplements/new"
    end
  end

  def check_request_is_suppliable
    unless @request&.user == current_user && @request.is_suppliable
      redirect_back(fallback_location: root_path)
    end
  end

  def define_request
    if params[:request_id]
      @request = Request.find(params[:request_id])
    elsif params[:request_supplement][:request_id]
      @request = Request.find(params[:request_supplement][:request_id])
    end
  end

  def request_supplement_params
    params.require(:request_supplement).permit(
      :request_id,
      :body,
    )
  end
end
