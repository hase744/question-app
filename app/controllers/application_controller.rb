class ApplicationController < ActionController::Base
  class Forbidden < ActionController::ActionControllerError; end
  class IpAdressRejected < ActionController::ActionControllerError; end
  include CommonConcern
  include CommonMethods
  include StripeMethods
  include FormConfig
  include Variables
  include ViewConcern
  include OperationConfig
  include ErrorHandlers if Rails.env.production?
  include AccessHandlers
  include ImageGenerator

  layout :layout_by_resource
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_nav_item
  Stripe.api_key = Rails.env.production? ? ENV['STRIPE_SECRET_KEY'] : ENV['STRIPE_SECRET_KEY_DEV']

  def create_error_log(e)
    @error_log = ErrorLog.new(
      error_class: e.class,
      error_message: e.message,
      error_backtrace: e.backtrace,
      method: request.method,
      controller: controller_name, 
      action: action_name, 
      id_number: params[:id], 
      parameter: params, 
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

  #ユーザー登録の時に名前を登録できるようにする。
  protected
  def configure_permitted_parameters
    added_attrs = [ :email, :name, :password, :password_confirmation ]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end
end
