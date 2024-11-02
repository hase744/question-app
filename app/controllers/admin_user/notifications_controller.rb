class AdminUser::NotificationsController < AdminUser::Base
  def index
    @notifications = Notification
      .from_latest_order
      .page(params[:page])
      .per(50)
  end

  def new
    @notification = Notification.new(title: "テスト", description: '中身の説明')
  end

  def edit
    @notification = Notification.find(params[:id])
  end

  def show
    @notification = Notification.find(params[:id])
  end

  def create
    if notification_params[:user_id] == '0'
      notifications = User.all.map do |user|
        notification_params.merge(
          user_id: user.id, 
          created_at: DateTime.now,
          updated_at: DateTime.now,
          )
      end
      Notification.insert_all(notifications)
    else
      Notification.create(notification_params)
    end
  end

  def notification_params
    params.require(:notification).permit(
      :user_id,
      :title,
      :description
    )
  end
end
