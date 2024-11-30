class AnnouncementReceipt < ApplicationRecord
  belongs_to :announcement
  belongs_to :user
  after_commit :update_notifications

  def update_notifications
    if saved_change_to_id? #新規のデータである
      Notification.create(
        user_id: user.id, 
        title: self.announcement.title,
        description: self.announcement.description,
        published_at: self.announcement.published_at,
        controller: "announcements",
        action: "show",
        id_number: self.announcement.id,
        created_at: DateTime.now,
        updated_at: DateTime.now,
        )
    else
      notification = Notification.find_by(
        controller: "announcements",
        action: "show",
        id_number: self.announcement_id,
      )
      if destroyed?
        notification.destroy
      else
        notification.update(
          user: self.user
        )
      end
    end
  end
end