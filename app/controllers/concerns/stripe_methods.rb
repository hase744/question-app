class ProfitMismatchError < StandardError
  def initialize(total_profit, available_amount)
    super("Profit (#{total_profit}) does not match available amount (#{available_amount})")
  end
end

module StripeMethods
  def get_finance_info
    if user_signed_in? && current_user.stripe_account_id
      @profit_sum = 0
      @margin_sum = 0
      @balance_amount = 0
      @balance = Stripe::Balance.retrieve(
        {stripe_account: current_user.stripe_account_id}
        )
      @payouts = Stripe::Payout.list({
        limit: 10, # 取得する送金記録の数を指定（例：10件）
        #status: 'in_transit'
      }, {
        stripe_account: current_user.stripe_account_id # ConnectアカウントIDを指定
      })
      if @payouts&.first&.created
        last_credited_at = Time.at(@payouts&.first&.created)
      else
        last_credited_at = Time.now
      end
      
      @pending_amount = @balance.pending[0].amount
      @available_amount = @balance.available[0].amount
      puts "料金"
      puts @pending_amount
      puts @available_amount
      @balance_amount = @pending_amount + @available_amount
      transactions = Transaction.all
        .left_joins(:service)
        .where(service:{user: current_user}, is_delivered:true)
        .where("delivered_at > ?", last_credited_at)
        .order(created_at: :DESC)

      @total_revenue = transactions.sum(:price)
      @total_margin = transactions.sum(:margin)
      @total_profit = @total_revenue - @total_margin

      puts @total_profit != @available_amount

      if @balance_amount - 200 < 0
        @deposit_amount = 0
      else
        @deposit_amount = @balance_amount - 200
      end
      raise ProfitMismatchError.new(@total_profit, @available_amount) if @total_profit != @available_amount
    end
  end

  def send_to_root_user(user)
    @balance = Stripe::Balance.retrieve(
      {stripe_account: user.stripe_account_id}
      )
    @pending_amount = @balance.pending[0].amount
    @available_amount = @balance.available[0].amount
    puts @pending_amount
    puts @available_amount
    @balance_amount = @pending_amount + @available_amount
    transfer = Stripe::Transfer.create({
      amount: @available_amount,
      currency: 'jpy',
      destination: ENV["ROOT_ACCOUNT_ID"], 
      description: 'Transfer to admin account minus fee',
    }, {
      stripe_account: user.stripe_account_id,
    })
  end
end