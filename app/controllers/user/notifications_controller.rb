class User::NotificationsController < User::Base
  before_action :check_login
  before_action :identify_user, only:[:show]
  def index
  end

  def notification_bar
    @notifications = Notification.solve_n_plus_1
      .where(user: current_user)
      .published
      .order(is_notified: :asc, id: :desc)
      .page(params[:page])
      .per(15)
    render partial: "user/notifications/notification_bar", locals: { contents: @notifications}
  end

  def notification_cells
    @notifications = Notification.solve_n_plus_1
      .where(user: current_user)
      .published
      .order(is_notified: :asc, id: :desc)
      .page(params[:page])
      .per(15)
    render partial: "user/notifications/notification_cells", locals: { contents: @notifications}
  end
  
  def show
    notification = Notification.find(params[:id])
    path = Rails.application.routes.generate_extras({:controller=>"user/#{notification.controller}", :action=>notification.action, :id=>notification.id_number})
    #redirect_to controller: notification.controller.to_sym, action: notification.actionotification.to_sym, id:notification.id_number
    if notification.parameter.present?
      redirect_to path[0]+notification.parameter
    else
      redirect_to path[0]
    end
    Notification.published.where(controller: notification.controller, action: notification.action, id_number: notification.id_number).each do |n|
      n.update(is_notified:true)
    end
  end

  def all_notified
    Notification.all
      .where(user: current_user, is_notified: false)
      .published
      .update_all(is_notified: true)
    redirect_back(fallback_location: root_path)
  end

  private def identify_user
    notification = Notification.find(params[:id])
    if notification.user != current_user
      redirect_to new_user_session_path
    end
  end
end
