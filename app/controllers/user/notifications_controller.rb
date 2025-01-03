class User::NotificationsController < User::Base
  before_action :check_login
  before_action :identify_user, only:[:show]
  after_action :update_unread_notifications, only:[:show, :acknowledge_all]
  def index
  end

  def bar
    @notifications = current_user.notifications.recent(params)
    render partial: "user/notifications/notification_bar", locals: { contents: @notifications}
  end

  def cells
    @notifications = current_user.notifications.recent(params)
    render partial: "user/notifications/notification_cells", locals: { contents: @notifications}
  end

  def show
    notification = Notification.find(params[:id])
    redirect_to notification.redirect_path
    puts "リダイレクト"
    puts notification.redirect_path
    same_path_notifications = current_user.notifications
      .published
      .where(
        controller: notification.controller, 
        action: notification.action, 
        id_number: notification.id_number
        )
    same_path_notifications.update_all(is_read: true)
  end

  def acknowledge_all
    notifications = current_user.notifications.published.unnotified
    if notifications.update_all(is_read: true)
      flash.notice = '全て既読にしました'
    else
      flash.notice = 'エラー'
    end
    redirect_back(fallback_location: root_path)
  end

  private def update_unread_notifications
    current_user.update_unread_notifications
  end

  private def identify_user
    notification = Notification.find(params[:id])
    if notification.user != current_user
      redirect_to new_user_session_path
    end
  end
end
