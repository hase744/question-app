class AdminUser::AnnouncementsController < AdminUser::Base
  before_action :define_annoucement, only: [:show, :edit, :destroy, :update]
  before_action :update_notifications, only: [:create, :destroy, :update]
  def index
		@announcements = Announcement
    	.where("announcements.title LIKE ?", "%#{params[:title]}%")
			.from_latest_order
			.page(params[:page])
			.per(50)
  end

  def show
  end

  def new
    @announcement = Announcement.new(title: 'アナウンスのテスト', body:'アナウンスの文章')
  end

  def edit
  end

	def destroy
    @announcement = Announcement.find(params[:id]).destroy
    if @announcemen.destroy
			flash.notice = "削除しました"
			redirect_to admin_user_announcements_path
    else
      render action: "show"
    end
	end

  def remove_file
    @announcement_item = AnnouncementItem.find(params[:id])
    @announcement = @announcement_item.announcement
    if @announcement_item.delete
      flash.notice = "削除しました"
      redirect_back(fallback_location: root_path)
    end
  end

  def create
    @announcement = Announcement.new(announcement_params)
    generate_items
    ActiveRecord::Base.transaction do
      if @announcement.save
		  	flash.notice = "作成しました"
		  	redirect_to admin_user_announcement_path(@announcement.id)
      else
        render action: "new"
      end
    end
  end

	def update
    @announcement.assign_attributes(announcement_params)
    generate_items
    ActiveRecord::Base.transaction do
	  	if @announcement.save
	  		flash.notice = "更新しました"
	  		redirect_to admin_user_announcement_path(@announcement.id)
      else
        render action: "edit"
      end
    end
	end

  def update_notifications
    @recipients&.each do |recipient|
      recipient.update_unread_notifications
    end
  end

  def define_annoucement
    @announcement = Announcement.find(params[:id])
    @recipients = @announcement.recipients
  end

  def announcement_params
    params.require(:announcement).permit(
      :condition_type,
      :title,
	  	:published_at,
      :body,
      :description,
    )
  end

  def generate_items
    return [] unless params.dig(:items, :file).present?
    params.dig(:items, :file)&.map do |file|
      item = @announcement.items.new()
      item.process_file_upload = true
      item.file = file
      item 
    end
  end
end
