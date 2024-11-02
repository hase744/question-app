class AdminUser::AnnouncementReceiptsController < AdminUser::Base
  def show
    @announcement_receipt = AnnouncementReceipt.find(params[:id])
  end

  def index
    @announcement_receipts = AnnouncementReceipt
			.from_latest_order
			.page(params[:page])
			.per(50)
  end

  def new
    @announcement_receipt = AnnouncementReceipt.new
		@announcement_receipt.announcement_id = params[:announcement_id] if params[:announcement_id]
		@announcement_receipt.user_id = params[:user_id] if params[:user_id]
    @announcements  = Announcement
			.where("announcements.title LIKE ?", "%#{params[:title]}%")
			.where(condition_type: 'individual')
			.from_latest_order
			.page(params[:page])
			.per(50)
    @users = User
			.where("users.name LIKE ?", "%#{params[:name]}%")
			.from_latest_order
			.page(params[:page])
			.per(50)
  end

  def edit
    @announcement_receipt = AnnouncementReceipt.find(params[:id])
    @announcements  = Announcement
			.where("announcements.title LIKE ?", "%#{params[:title]}%")
			.where(condition_type: 'individual')
			.from_latest_order
			.page(params[:page])
			.per(50)
    @users = User
			.where("users.name LIKE ?", "%#{params[:name]}%")
			.from_latest_order
			.page(params[:page])
			.per(50)
  end

  def create
    @announcement_receipt = AnnouncementReceipt.new(announcement_receipt_params)
		if @announcement_receipt.save
			flash.notice = "作成しました"
			redirect_to admin_user_announcement_receipt_path(@announcement_receipt.id)
    else
      render action: "new"
    end
  end

	def destroy
    if AnnouncementReceipt.find(params[:id]).destroy
			flash.notice = "削除しました"
			redirect_to admin_user_announcement_receipts_path
    else
      render action: "show"
    end
	end

  def announcement_receipt_params
    params.require(:announcement_receipt).permit(
      :user_id,
      :announcement_id
    )
  end
end
