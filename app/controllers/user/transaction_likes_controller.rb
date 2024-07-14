class User::TransactionLikesController < User::Base
  before_action :check_login, only:[:show, :create]
  layout 'small'
  def show
    @transactions = Transaction
      .where(id: current_user.transaction_likes.pluck(:transaction_id))
      .page(params[:page])
      .per(20)
  end

  def create
    puts "クリエイト"
    transaction = Transaction.find(params[:id])
    like = transaction.likes.find_by(user: current_user)
    if like.present?
      like.destroy
      render json: false
    else
      transaction.likes.create(user: current_user)
      render json: true
    end
  end
end
