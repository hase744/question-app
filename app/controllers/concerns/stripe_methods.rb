class ProfitMismatchError < StandardError
  def initialize(total_profit, available_amount)
    super("Prifit (#{total_profit}) does not match available amount (#{available_amount})")
  end
end

class NonZeroBalanceError < StandardError
  def initialize(pending_amount, available_amount)
    message = ""
    message += "pending_amount is #{pending_amount}" if pending_amount > 0
    message += "available_amount is #{available_amount}" if available_amount > 0
    super(message)
  end
end

class ZeroTransferAmountError < StandardError
  def initialize(revenue)
    super("revenue is #{revenue}")
  end
end

module StripeMethods
  def update_payments
    if current_user.stripe_account_id
      payouts = Stripe::Payout.list({
        limit: 100, # 取得する送金記録の数を指定（例：10件）
        #status: 'in_transit'
        }, {
          stripe_account: current_user.stripe_account_id # ConnectアカウントIDを指定
        }
      )
      payouts.each do |payout|
        payout_model = @payouts.find { |p| p.stripe_payout_id == payout.id }
        if payout_model.present? && payout_model&.status_name != payout.status
          payout_model.update(status_name: payout.status) 
        end
      end
    end
  end

  def get_finance_info
    @payouts = current_user.payouts
      .order(executed_at: :desc)
      .page(params[:page])
      .per(50)
    Payouts::UpdateJob.perform_later(current_user)
    if user_signed_in?
      @transactions = current_user.transactions_from_last_deposit
      @total_revenue = @transactions&.sum(:price) || 0
      @total_margin = @transactions&.sum(:margin) || 0
      @total_profit = @transactions&.sum(:profit) || 0
      @amount_to_transfer = [@transactions.sum(:profit) - 200, 0].max
    end
  end

  def detect_error
    return if current_user.stripe_account_id.nil?
    transactions_without_stripe_id = Transaction
      .left_joins(:service)
      .where(
        service:{user: current_user}, 
        is_transacted:true,
        stripe_transfer_id: nil
        )
    balance = Stripe::Balance.retrieve(
      {stripe_account: current_user.stripe_account_id}
      )
    total_profit = @transactions.sum(:profit)
    total_profit_with_stripe_id = transactions_without_stripe_id.sum(:profit)
    
    if total_profit != total_profit_with_stripe_id
      raise ProfitMismatchError.new(total_profit, total_profit_with_stripe_id)
    end

    @pending_amount = balance.pending[0].amount
    @available_amount = balance.available[0].amount
    if @pending_amount + @available_amount > 0
      raise NonZeroBalanceError.new(@pending_amount, @available_amount)
    end
  end

  def excute_unfinished_transactions
    transactions = Transaction
      .where(stripe_transfer_id: nil)
      .where(service:{user: current_user}, is_transacted:true)
    transactions.each do |transaction|
      if transaction.valid?
        transfer = Stripe::Transfer.create(
              amount: transaction.profit,
              currency: 'jpy',
              destination: current_user.stripe_account_id
        )
        transaction.stripe_transfer_id = transfer.id
        transaction.is_reveresed = transfer.reversed
        transaction.save
      end
    end
  end

  def execute_transfers # 最後に入金してから行われたtransaction全て
    raise ZeroTransferAmountError.new(@total_revenue) if @amount_to_transfer <= 0
    success = true
    @transactions.each do |transaction|
      if transaction.valid?
        transfer = Stripe::Transfer.create(
          amount: transaction.profit,
          currency: 'jpy',
          destination: current_user.stripe_account_id
        )

        unless transfer.reversed
          transaction.stripe_transfer_id = transfer.id
        end

        unless transaction.save
          success = false
        end
      else
        success = false
      end
    end
    success
  end

  def send_to_root_user(user)
    @balance = Stripe::Balance.retrieve(
      {stripe_account: user.stripe_account_id}
      )
    @pending_amount = @balance.pending[0].amount
    @available_amount = @balance.available[0].amount
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