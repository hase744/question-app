class Announcement < ApplicationRecord
  has_many :receipts, class_name: "AnnouncementReceipt", dependent: :destroy
  has_many :recipients, through: :receipts, source: :user, dependent: :destroy
  has_many :items, class_name: "AnnouncementItem", dependent: :destroy
  scope :published, -> { where.not(published_at: nil) }
  after_commit :update_notifications
  after_commit :update_receipts
  enum condition_type: [:individual, :all_users, :all_sellers, :all_buyers]
  accepts_nested_attributes_for :items, allow_destroy: true
  attr_accessor :notified_users
  before_validation :set_notified_users

  scope :to, ->(user){
    joins(:recipients)
    .where(
      receipts: { user_id: user&.id }
    )
  }
  scope :for_user, ->(user) {
    published
    .where.not(condition_type: :individual)
    .or(where(id: user&.announcement_receipts&.pluck(:announcement_id)))
  }

  def set_notified_users #通知させるユーザーが変化した場合、以前させていた通知を消すため
    return unless will_save_change_to_condition_type?
    case condition_type_was
    when 'individual'
      self.notified_users = self.recipients
    when 'all_users'
      self.notified_users = User.all
    when 'all_sellers'
      self.notified_users = User.where(is_seller: true)
    when 'all_buyers'
      self.notified_users = User.where(is_seller: false)
    end
  end

  def self.selector_hash
    I18n.t('activerecord.attributes.announcement/condition_type').invert
  end

  def type_name_japanese
    I18n.t("activerecord.attributes.announcement/condition_type.#{condition_type}")
  end

  def update_notifications
    if saved_change_to_id? #新規のデータである
      Notification.create_batch(self)
    else
      notifications = Notification.where(
        controller: "announcements",
        action: "show",
        id_number: self.id,
      )
      if destroyed?
        notifications.delete_all
      elsif saved_change_to_condition_type?
        notifications.delete_all
        unless self.condition_type == 'individual'
          Notification.create_batch(self)
        end
        update_user_unread_notifications(users: notified_users)
      else
        users = User.where(id: notifications.pluck(:user_id))
        notifications.update_all(
          published_at: self.published_at,
          title: self.title,
          description: self.body,
        )
        update_user_unread_notifications(users: users)
      end
    end
  end

  def update_receipts #通知させる対象が変化
    if saved_change_to_condition_type?
      self.receipts.destroy_all
    end
  end

  def self.schedule_notification
    announcements = self.all
      .where(is_read: false)
      .where('published_at <= ?', DateTime.now)
    announcements.each do |announcement|
      Notification.create_batch(announcement)
    end
  end

  def update_user_unread_notifications(users:)
    return if users.blank?
    #未来に公開するアナウンスなら、ユーザー毎の通知の個数の更新日時を更新
    if DateTime.now < self.published_at
      users.unread_notifications_change_later_than(self.published_at).update_all(
        unread_notifications_next_change_at: self.published_at
      )
    else #現在公開するアナウンスなら、ユーザー毎の通知の個数を更新
      ActiveRecord::Base.connection.execute(<<-SQL)
        UPDATE users
        SET unread_notifications = (
          SELECT COUNT(*)
          FROM notifications
          WHERE notifications.user_id = users.id
            AND notifications.is_read = false
            AND notifications.published_at <= '#{DateTime.now}'
        )
        WHERE users.id IN (#{users.pluck(:id).join(',')})
      SQL
    end
  end
end
