class User::Base < ApplicationController
  before_action :check_operation_state
  before_action :check_error
  before_action :check_deleted_account
  after_action :create_access_log
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  def create_access_log
    if user_signed_in?
      puts "元のIPアドレス"
      puts @remote_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip
      AccessLog.create(
        user: current_user, 
        ip_adress: request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip,
        method: request.method,
        action: action_name, 
        controller: controller_name, 
        id_number: params[:id], 
        parameter: params
        )
      if AccessLog.count > 100000
        AccessLog.where(user: current_user).order(created_at: "DESC").last.destroy
      end
    end
  end

  def check_stripe_customer
    if !current_user.is_stripe_customer_valid?
      flash.notice = "クレジットカードを登録してください。"
      redirect_to user_cards_path
    end
  end

  #def check_user_status
  #    if user_signed_in?
  #        user_status = UserStatus.where("user_id = ? && start_at <= ?",current_user.id, DateTime.now).order(start_at: "ASC").last
  #        if user_status.present?
  #            allowed_controllers = ["sessions", "alerts", "abouts", "inquiries"]
  #            if user_status.state == "suspended" && !allowed_controllers.include?(controller_name)
  #                redirect_to user_alerts_path
  #            end
  #        end
  #    end
  #end

  def check_error
      if params[:error] != nil && params[:error] != ""
        @error = params[:error]
      end
  end

  def check_deleted_account
      puts "アカウント状況"
      puts controller_name
      puts action_name
      if controller_name == "devise" && action_name == "registrations"
          puts "新規登録"
      end
  end
    
  def check_operation_state
    state = current_state
    puts "オペレーション"
    puts state
    if admin_user_signed_in? || for_admin_user
      puts current_admin_user.email
    else
      if state
        puts "システム状況" + state
        puts controller_name
        case state
        when "register" then
          puts "登録のみ"
          if state_register
          else
            flash.notice = "現在その機能はご利用いただけません。"
            puts "アクセス失敗"
            redirect_to_previous_path
          end
        when "suspended" then
          puts "システム停止"
          if state_suspended
          else
            flash.notice = "現在システムは停止しています。"
            redirect_to_previous_path
          end
        when "browse" then
          puts "閲覧のみ"
          if state_browse then
          else
            flash.notice = "現在その機能はご利用いただけません。"
            redirect_to_previous_path
          end
        when "running" then
          puts "稼働"
        else
          puts "その他"
        end
        
      end
    end
  end
    
  def redirect_to_previous_path
    #if request.referer
    #   redirect_to request.referer
    #else
    #   redirect_to abouts_path
    #end
    redirect_to abouts_path
  end

  def state_suspended
    if [
      "abouts",
      "admin",
      "active_admins",
      "sessions",
      "dashboard",
      "alerts"
      ].include?(controller_name)
      true
    else
      false
    end
  end
  
  def state_browse
    if [
      "create",
      "delete",
      "destroy",
      "edit",
      "new",
      "update",
      "inquiries",
    ].include?(action_name)
      false
    else
      true
    end
  end

  def state_register
    if controller_name == "services" && action_name == "show" #自分のサービスページを閲覧
      if user_signed_in? && Service.find(params[:id]).user == current_user
        true
      else
        false
      end
    elsif controller_name == "requsts" && action_name == "show" #自分の依頼ページを閲覧
      if user_signed_in? && Request.find(params[:id]).user == current_user
        true
      else
        false
      end
    elsif [
      "services",
      "requests",
      "accounts",
      "abouts",
      "admin",
      "active_admins",
      "cards",
      "configs",
      "confirmations",
      "connects",
      "dashboard",
      "inquiries",
      "images",
      "notifications",
      "omniauth_callbacks",
      "payments",
      "passwrords",
      "posts",
      "registrations",
      "sessions",
      "transactions",
      "unlocks",
      "inquiries",
      "alerts"
      ].include?(controller_name)
      true
    else
      #if controller_path.include?("admin")
      #   true
      #else
      #   false
      #end
      false
    end
  end

  def check_meta_tag
    @twitter_title = "コレテク　~ノウハウを売買するQAサイト~"
    @twitter_site = "@3UJVrqxCS0V4bin"
    @twitter_creator = "@3UJVrqxCS0V4bin"
    @og_title = "コレテク　~ノウハウを売買するQAサイト~"
    @og_url = "#{ENV['PROTOCOL']}://#{ENV['HOST']}"
    @og_description = "コレテクとは質問や相談をし合うスキルシェアサービスです。相談内容は公開され、誰でも閲覧できるのが特徴！登録して悩みを相談しよう！"
    @og_site_name = "コレテク"
    @og_image  = "#{ENV['PROTOCOL']}://#{ENV['HOST']}/corretech_large_icon.png"
  end
  
  private def check_login
    if !user_signed_in?
      session[:path_params] = params if request.method == 'GET'
      redirect_to new_user_session_path
    end
  end
end