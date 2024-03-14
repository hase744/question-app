class User::HomesController < ApplicationController
  layout "with_footer"
  def show
    @services = Service.all.order(:total_sales_numbers).limit(10)
    @users = User.where(is_seller:true).all.order(:total_sales_numbers).limit(10)
    @transactions = Transaction.delivered.order(:total_views).limit(12)
    @transactions.each do |t|
      t.set_item
    end
  end
end
