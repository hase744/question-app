class Announcement < ApplicationRecord
  has_many :receipts, class_name: "AnnouncementReceipt", dependent: :destroy
  has_many :recipients, through: :receipts, source: :user, dependent: :destroy
  has_many :items, class_name: "AnnouncementItem", dependent: :destroy
  scope :published, -> { where.not(published_at: nil) }
  after_commit :update_notifications
  enum condition_type: [:individual, :all_users, :all_sellers, :all_buyers]
  accepts_nested_attributes_for :items, allow_destroy: true

  scope :for_user, ->(user) {
    published
    .where.not(condition_type: :individual)
    .or(where(id: Announcement.joins(:recipients).where(receipts: { user_id: user&.id })))
  }

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
      else
        notifications.update_all(
          published_at: self.published_at,
          title: self.title,
          description: self.body,
        )
      end
    end
  end

  def self.schedule_notification
    announcements = self.all
      .where(is_notified: false)
      .where('published_at <= ?', DateTime.now)
    announcements.each do |announcement|
      Notification.create_batch(announcement)
    end
  end
end
