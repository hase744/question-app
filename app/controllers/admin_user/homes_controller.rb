class AdminUser::HomesController < AdminUser::Base
  def show
    @inquiries = Inquiry.all.from_latest_order
    @inquiries = @inquiries
      .page(params[:page])
      .per(50)
  end
end
