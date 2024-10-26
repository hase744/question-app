module RedirectHandlers
  extend ActiveSupport::Concern
  included do
    before_action :check_session_point # before_action added here
    before_action :store_current_location
  end

  def after_sign_in_path_for(resource)
    if session[:path_params].present? && lookup_context.exists?(session.dig(:path_params, 'action'), session.dig(:path_params, 'controller'))
      previous_path = url_for(
        controller: session.dig(:path_params, 'controller'), 
        action: session.dig(:path_params, 'action'), 
        id: session.dig(:path_params, 'id'), 
        only_path: true)
      previous_path
    else
      user_account_path(current_user.id)
    end
  end

  def after_sign_out_path_for(resource)
    if session[:path_params].present? && lookup_context.exists?(session.dig(:path_params, 'action'), session.dig(:path_params, 'controller'))
      previous_path = url_for(
        controller: session.dig(:path_params, 'controller'), 
        action: session.dig(:path_params, 'action'), 
        id: session.dig(:path_params, 'id'), 
        only_path: true)
      previous_path
    else
      user_homes_path
    end
  end

  def check_session_point
    unless controller_name == "payments"
      session[:point] == nil
      session[:payment_service_id] = nil
      session[:payment_transaction_id] = nil
    end
  end

  def store_current_location
    # 現在のリクエストがGETリクエストでない場合やDevise関連のリクエストは除外
    return unless request.get? && !request.xhr? && !devise_controller?

    # 現在のコントローラーとアクションをセッションに保存
    session[:previous_controller] = controller_name
    session[:previous_action] = action_name
  end
end