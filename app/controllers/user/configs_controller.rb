class User::ConfigsController < User::Base
before_action :check_login
Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  def show
    @user = current_user
    #list = Stripe::PaymentIntent.list({limit: 3, customer: current_user.stripe_customer_id})
    #list = Stripe::PaymentIntent.list({limit: 3, customer: current_user.stripe_customer_id})
    #puts "リスト"
    #puts list
    @profit_sum = 0
    @margin_sum = 0
    @balance_amount = 0
    @is_add_up = false
    if current_user.stripe_account_id
      @balance = Stripe::Balance.retrieve(
        {stripe_account: current_user.stripe_account_id}
        )
        puts "口座"
        puts @balance
        puts @balance.available
        puts @balance.available[0].amount

      @pending_amount = @balance.pending[0].amount
      @available_amount = @balance.available[0].amount
      @balance_amount = @pending_amount + @available_amount
      Transaction.left_joins(:service).where(service:{user: current_user}, is_delivered:true).order(created_at: :DESC).each do |transaction|
        @profit_sum += transaction.price
        @profit_sum -= transaction.margin
        @margin_sum += transaction.margin
        puts @profit_sum 
        if @profit_sum == @balance_amount
          puts "balance"
          @is_add_up = true
          break
        end
      end

      #strioe上の利益の合計額とサーバー内の合計額が合うか確認
      if !@is_add_up
        @profit_sum = "---"
        @margin_sum = "---"
      end

      if @balance_amount == 0
        @profit_sum = 0
        @margin_sum = 0
      end

      puts "合計"
      puts @profit_sum
      puts @margin_sum
      @account = Stripe::Account.retrieve(current_user.stripe_account_id)
      #puts @account
      puts @account.payouts_enabled
      puts @account.charges_enabled
      puts @account.requirements.disabled_reason == ""
      puts @account.requirements.disabled_reason == nil
      puts !@account.requirements.disabled_reason.present?
      #未申請の人は全てfalse ＃審査済みは== ""以外true
      #@account = Stripe::Account.retrieve("acct_1LGbQX2HHuPySESJ")
      #puts @account.payouts_enabled
      #puts @account.charges_enabled
    end
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
    Transaction.where(seller:current_user ,is_delivered:false, is_canceled:false).each do |transaction|
      if !transaction.is_rejected
        exist = true
        break
      end
    end
    return
  end

  private def user_params
    params.require(:user).permit(
      :can_receive_message,
      :can_email_advert,
      :can_email_message,
      :is_published,
      :is_seller
    )
  end
end
