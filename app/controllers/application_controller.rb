class ApplicationController < ActionController::Base
  class Forbidden < ActionController::ActionControllerError; end
  class IpAdressRejected < ActionController::ActionControllerError; end
  include CommonConcern
  include CommonMethods
  include StripeMethods
  include OperationConfig
  include FormConfig
  include Variables
  include ViewConcern
  include ErrorHandlers if Rails.env.production?
  layout :layout_by_resource
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :get_path
  before_action :set_view_value
  before_action :check_user_state
  before_action :check_session_point
  before_action :set_current_nav_item
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']

  def create_error_log(e)
    @error_log = ErrorLog.new(
      error_class: e.class,
      error_message: e.message,
      error_backtrace: e.backtrace,
      request_method: request.method,
      request_controller: controller_name, 
      request_action: action_name, 
      request_id_number: params[:id], 
      request_parameter: params, 
      )
    if user_signed_in?
      @error_log.user = current_user
    end
    if @error_log.save
      @error_log
    end
  end

  def layout_by_resource
    if devise_controller?
      'small'
    else
      'application'
    end
  end

  def set_view_value
    gon.layout = "normal"
    gon.is_loaded = true
    gon.user_signed_in = user_signed_in?
    gon.tweet_text = "コレテクとは質問や相談をし合うスキルシェアサービスです。相談内容は公開され、誰でも閲覧できるのが特徴！登録して悩みを相談しよう！"
  end

  require 'nkf'

  def check_user_state
    if user_signed_in?
      allowed_controllers = ["sessions", "alerts", "abouts", "inquiries"]
      puts current_user.is_suspended
      if current_user.is_suspended && !allowed_controllers.include?(controller_name)
        redirect_to user_alerts_path
      end

      if current_user.is_deleted
        reset_session
        flash.alert = "既に退会済みです"
      end
    end
  end

  def save_models
    models_to_save = [@service, @request, @transaction, @item].compact
    models_to_save.all?(&:save)
  end

  def revive
    user = Usse.find_by(reset_password_token: params[:reset_password_token])
  
    if user.present? && user.is_deleted
      user.update(is_deleted:false)
      redirect_to new_user_session_path
    end
  end

  def after_sign_in_path_for(resource)
    puts request.path_info
    puts "パラメータ"
    puts session[:path_params]
    if request.path_info == "/admin/login" 
      admin_dashboard_path
    elsif session[:path_params].present?
      if session[:path_params]['service_id']
        return url_for(
          controller: session[:path_params]['controller'],
          action: session[:path_params]['action'],
          service_id: session[:path_params]['service_id'],
          )
      end
      if session[:path_params]['id']
        return url_for(
          controller: session[:path_params]['controller'],
          action: session[:path_params]['action'],
          id: session[:path_params]['id'],
          )
      end
        url_for(
          controller: session[:path_params]['controller'],
          action: session[:path_params]['action'],
        )
    else
      user_account_path(current_user.id) # ログイン後に遷移するpathを設定
    end
  end

  def after_sign_out_path_for(resource)
    user_transactions_path # ログアウト後に遷移するpathを設定
  end

  def from_now(datetime)
    if datetime == nil
      "--:--"
    else
      past_time = datetime - DateTime.now#現在から何秒後
      if 0 < past_time
        word = "後"
      else
        word = "前"
      end
  
      difference = past_time.abs #絶対値
      minute = difference/60
      hour = minute/60
      day = hour/24
      week = day/7
      month = week/4
      year = day/365
      
      if (minute).to_i < 60#60分未満
        "#{minute.to_i }分"
      elsif hour.to_i < 24 #24時間未満
        "#{hour.to_i }時間"
      elsif day.to_i < 7 #７日未満
        "#{day.to_i}日"
      elsif week.to_i < 4 #4週間未満
        "#{week.to_i }週間"
      elsif  month.to_i < 12 #12ヶ月未満s
        "#{month.to_i }ヶ月"
      else
        "#{year.to_i}年"
      end
    end
  end

  def convert_path(controller, action, id)
    paths = {"rooms" => {"show" => room_path(id)}}
    paths[controller][action]
  end
  
  def half_size_kana(word)
    NKF.nkf('-w -Z4 -x', word.tr('あ-ん', 'ア-ン'))
  end

  def half_size_number(word)
    word.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')
  end

  def image_extension
    []
  end

  def get_path
    puts "パス情報"
    puts controller_name
    puts action_name
    puts request.method
    puts controller_path
    puts admin_user_signed_in?
    if user_signed_in?
      current_user.update(last_login_at: DateTime.now)
    end
    if controller_name == "abouts"
      @index_link = true
    elsif controller_name == "transactions" || action_name == "index"
      @index_link = true
    else
      @index_link = false
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
  
  def message_receivable(user)
    if user_signed_in?
      if Relationship.exists?(followee:user, follower:current_user, is_blocked:true)
        false
      elsif user.can_receive_message
        true
      elsif Contact.exists?(user:user, destination: current_user)
        true
      end
    elsif user.can_receive_message
      true
    else
      false
    end
  end
  
  def check_session_point
    unless controller_name == "payments"
      session[:point] == nil
      session[:payment_service_id] = nil
      session[:payment_transaction_id] = nil
    end
  end
  #ユーザー登録の時に名前を登録できるようにする。
  protected
  def configure_permitted_parameters
    added_attrs = [ :email, :name, :password, :password_confirmation ]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end
end
