class User::AnnouncementsController < User::Base
  layout "about"
  def index
    @announcements = Announcement.published
      .order(published_at: :desc)
      .where("announcements.title LIKE ? ", "%#{params[:name]}%")
      .for_user(current_user)
      .page(params[:page])
      .per(50)
  end

  def show
    @announcement = Announcement.find(params[:id])
  end
end
