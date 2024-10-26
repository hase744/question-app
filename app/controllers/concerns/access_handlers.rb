module AccessHandlers
  extend ActiveSupport::Concern
  included do
    before_action :check_operation_state
    before_action :check_user_state
  end

  def check_operation_state
    name_space = controller_path.split('/').first
    return true if name_space == "admin"
    case current_state
    when "register" then
      return if state_register_access_condition
      unless request.method == 'GET'
        flash.notice = "現在その機能はご利用いただけません。"
        if  name_space == 'devise'
          redirect_to user_homes_path
        else
          redirect_back fallback_location
        end
      end
      raise RegistrationOnlyAccessError, "登録、出品のみ可能です。"
    when "suspended" then
      return if state_suspended_access_condition
      unless request.method == 'GET'
        flash.notice = "現在システムは停止しています。"
        redirect_back fallback_location
      end
      sign_out(current_user) if user_signed_in?
      raise ReadOnlyAccessError, "現在システムは停止しています。"
    when "browse" then
      return if state_browse_access_condition
      unless request.method == 'GET'
        flash.notice = "現在その機能はご利用いただけません。"
        if  name_space == 'devise'
          redirect_to user_homes_path
        else
          redirect_back fallback_location
        end
      end
      sign_out(current_user) if user_signed_in?
      #raise SuspendedAccessError, "閲覧のみ可能です。"
    when "running" then
    else
    end
  end

  def state_suspended_access_condition
    if %w[
      abouts
      admin
      active_admins
      alerts
      dashboard
      ].include?(controller_name)
      true
    else
      false
    end
  end
  
  def state_browse_access_condition
    if %w[
    ].include?(controller_name)
      true
    else
      false
    end
  end

  def state_register_access_condition
    return false if controller_name == 'accounts' && action_name == 'index'
    return false if controller_name == 'accounts' && action_name == 'show' && User.find(params[:id]) != current_user
    return false if controller_name == 'services' && action_name == 'index'
    return false if controller_name == 'services' && action_name == 'show' && Service.find(params[:id]).user != current_user
    if %w[
      abouts
      accounts
      active_admins
      admin
      alerts
      balance_records
      cards
      configs
      confirmations
      connects
      dashboard
      images
      inquiries
      notifications
      omniauth_callbacks
      orders
      point_records
      payments
      passwrords
      posts
      registrations
      request_likes
      service_likes
      sessions
      unlocks
      payouts
    ].include?(controller_name)
      true
    else
      false
    end
  end

  def check_user_state
    if params[:commit] != "ログイン" && user_signed_in?
      allowed_controllers = ["sessions", "alerts", "abouts", "inquiries"]
      if current_user.is_suspended && !allowed_controllers.include?(controller_name)
        redirect_to user_alerts_path
      end

      if current_user.is_deleted
        reset_session
        flash.alert = "既に退会済みです"
      end
    end
  end

  def for_admin_user
    if admin_user_signed_in? 
      true
    elsif controller_name == "dashboard" 
      true
    elsif controller_name == "sessions"
      true
    else
      false
    end
  end
end