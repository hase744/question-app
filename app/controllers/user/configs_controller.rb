class User::ConfigsController < User::Base
  before_action :check_login
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  layout :choose_layout

  private def choose_layout
    case action_name
    when "show"
      "application"
    else
      "small"
    end
  end

  def show
    get_finance_info
    @user = current_user
    @account = Stripe::Account.retrieve(current_user.stripe_account_id)
  end

  def edit
    @user = current_user
  end

  def destroy
    if current_user.update(is_deleted:true)
      flash.notice = "退会しました"
      redirect_to new_user_session_path
    end
  end

  def update
    if current_user.update(user_params)
      flash.notice =  "設定を更新しました。"
      redirect_to user_configs_path
    else
      @user = current_user
      render action: "edit"
    end
  end

  #01をtrue, falseに変換
  def binary_to_boolean
    {"0"=>false, "1"=>true}
  end

  private def ongoing_transaction_exist
    exist = false
    Transaction.where(seller:current_user ,is_transacted:false, is_canceled:false).each do |transaction|
      if !transaction.is_rejected
        exist = true
        break
      end
    end
    return
  end

  private def user_params
    params.require(:user).permit(
      :can_email_advert,
      :can_email_transaction,
      :is_published,
      :is_seller
    )
  end
end
