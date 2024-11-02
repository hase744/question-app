class AdminUser::AnnouncementsController < AdminUser::Base
  def index
		@announcements = Announcement
    	.where("announcements.title LIKE ?", "%#{params[:title]}%")
			.from_latest_order
			.page(params[:page])
			.per(50)
  end

  def show
		@announcement = Announcement.find(params[:id])
  end

  def new
    @announcement = Announcement.new(title: "テスト", body: '中身の説明')
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

	def destroy
    if Announcement.find(params[:id]).destroy
			flash.notice = "削除しました"
			redirect_to admin_user_announcements_path
    else
      render action: "show"
    end
	end

  def create
    @announcement = Announcement.new(announcement_params)
    if @announcement.save
			flash.notice = "作成しました"
			redirect_to admin_user_announcement_path(@announcement.id)
    else
      render action: "new"
    end
  end

	def update
    @announcement = Announcement.find(params[:id])
		if @announcement.update(announcement_params)
			flash.notice = "更新しました"
			redirect_to admin_user_announcement_path(@announcement.id)
    else
      render action: "edit"
    end
	end

  def announcement_params
    params.require(:announcement).permit(
      :condition_type,
      :title,
	  	:published_at,
      :body,
    )
  end
end
