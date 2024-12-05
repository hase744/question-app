class AdminUser::InquiriesController < AdminUser::Base
  def index
    @inquiries = Inquiry.all.from_latest_order
    @inquiries = @inquiries
      .page(params[:page])
      .per(50)
  end

  def edit
    @inquiry = Inquiry.find(params[:id])
  end

  def update
    @inquiry = Inquiry.find(params[:id])
    @inquiry.assign_attributes(inquiry_params)
    @inquiry.assign_attributes(
      admin_user: current_admin_user, 
      is_replied: true
      )
    if @inquiry.save
      Email::InquiryMailer.reply(@inquiry).deliver_now
    end
  end

  def show
    @inquiry = Inquiry.find(params[:id])
  end

  def inquiry_params
    params.require(:inquiry).permit(
      :answer
    )
  end
end
