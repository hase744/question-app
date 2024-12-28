class Notification < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: :user_id
  belongs_to :notifier, class_name: "User", foreign_key: :notifier_id, optional: true
  before_validation :set_default_values
  after_save -> { user.update_unread_notifications }

  scope :solve_n_plus_1, -> {
    includes(:user, :notifier)
  }

  scope :sort_by_date, -> {
    order(created_at: :ASC)
  }

  scope :recent, -> (params){
    solve_n_plus_1
    .published
    .order(is_read: :asc, published_at: :desc)
    .page(params[:page])
    .per(15)
  }

  def set_default_values
    self.published_at ||= DateTime.now
  end

  def self.create_announcement(announcement, user)
    self.create(
      user_id: user.id, 
      title: announcement.title,
      description: announcement.description,
      published_at: announcement.published_at,
      controller: "announcements",
      action: "show",
      id_number: announcement.id,
      created_at: DateTime.now,
      updated_at: DateTime.now,
      )
  end

  def self.create_batch(announcement)
    notification_params = {
      title: "運営からのお知らせ",
      description: announcement.title,
      published_at: announcement.published_at,
      controller: "announcements",
      action: "show",
      id_number: announcement.id,
    }
    users = User.where.not(confirmed_at: nil)
    case announcement.condition_type
    when "all_users"
      users = users.all
    when "all_sellers"
      users = users.where(is_seller: true)
    when "all_buyers"
      users = users.where(is_seller: false)
    else
      users = []
    end
    notifications = users.map do |user|
      notification_params.merge(
        user_id: user.id, 
        created_at: DateTime.now,
        updated_at: DateTime.now,
        )
    end
    self.insert_all(notifications) if notifications.present?
    announcement.update_user_unread_notifications(users: users)
  end
end
