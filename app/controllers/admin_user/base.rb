class AdminUser::Base < ApplicationController
  layout 'admin_user'
  before_action :check_admin_user
  after_action :save_current_path

  def check_admin_user
    unless admin_user_signed_in?
      redirect_to admin_user_session_path
    end
  end

  def after_sign_in_path_for(resource)
    if session[:admin_path_params].present? && lookup_context.exists?(session.dig(:admin_path_params, 'action'), session.dig(:admin_path_params, 'controller'))
      previous_path = url_for(
        controller: session.dig(:admin_path_params, 'controller'), 
        action: session.dig(:admin_path_params, 'action'), 
        id: session.dig(:admin_path_params, 'id'), 
        only_path: true)
      previous_path
    else
      user_account_path(current_user.id)
    end
  end

  def after_sign_out_path_for(resource)
    if session[:admin_path_params].present? && lookup_context.exists?(session.dig(:admin_path_params, 'action'), session.dig(:admin_path_params, 'controller'))
      previous_path = url_for(
        controller: session.dig(:admin_path_params, 'controller'), 
        action: session.dig(:admin_path_params, 'action'), 
        id: session.dig(:admin_path_params, 'id'), 
        only_path: true)
      previous_path
    else
      user_homes_path
    end
  end

  def save_current_path
    session[:admin_path_params] = params if request.method == 'GET'
  end
end