class User::Base < ApplicationController
  before_action :check_error
  after_action :create_access_log
  after_action :save_current_path
  include RedirectHandlers
  def create_access_log
    if user_signed_in?
      AccessLog.create(
        user: current_user, 
        ip_adress: request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip,
        method: request.method,
        action: action_name, 
        controller: controller_name, 
        id_number: params[:id], 
        parameter: params
        )
      current_user.last_login_at = DateTime.now
      current_user.save
      #if AccessLog.count > 100000
      #  AccessLog.where(user: current_user).order(created_at: "DESC").last.destroy
      #end
    end
  end

  def check_stripe_customer
    if !current_user.is_stripe_customer_valid?
      respond_to do |format|
        format.html do
          flash.notice = "クレジットカードを登録してください。"
          redirect_to user_cards_path
        end
        format.json do
          session[:message] = "クレジットカードを登録してください。"
          render json: {
            error: "クレジットカードを登録してください。",
            redirect_url: user_cards_path
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def check_error
    if params[:error] != nil && params[:error] != ""
      @error = params[:error]
    end
  end

  private def check_login
    unless user_signed_in? #ログインしていない
      redirect_to new_user_session_path
    end
  end

  def save_current_path
    session[:path_params] = params if request.method == 'GET'
  end
end