class User::InquiriesController < User::Base
  layout "about"
  def new
    @inquiry = Inquiry.new
    gon.layout = "about"
    if user_signed_in?
      @inquiries = Inquiry.where(user:current_user).page(params[:page]).per(10)
    end
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)
    if user_signed_in?
      @inquiry.user ||= current_user
      @inquiry.name ||= current_user.name
      @inquiry.email ||= current_user.email
    end

    if @inquiry.save
      flash.notice = "お問合せを送信しました。"
      redirect_to abouts_path
      Email::InquiryMailer.notify_amin_user(@inquiry.id).deliver_now
    else
      flash.notice = "お問合せに失敗しました。"
      redirect_to new_user_inquiries_path
    end
  end

  private def inquiry_params
    params.require(:inquiry).permit(
        :name, 
        :email,
        :body,
    )
  end
end
