class User::PayoutsController < User::Base
  layout "small"
  before_action :check_login, only:[:index, :show, :create]
  def index
    begin
      get_finance_info
      detect_error
    rescue ProfitMismatchError => e
      @error_message = e.message
    end
  end

  def show
    @payout = current_user.payouts.find(params[:id])
  end

  def create
    begin
      get_finance_info
      detect_error
      if execute_transfers
        payout = Stripe::Payout.create({
          amount: @amount_to_transfer, # Amount in cents (e.g., 1000 cents = $10.00)
          currency: 'jpy',
        }, {
          stripe_account:  current_user.stripe_account_id, # Connected account ID
        })
        transfer = Stripe::Transfer.create({
          amount: 200,
          currency: 'jpy',
          destination: ENV["ROOT_ACCOUNT_ID"], 
          description: 'Transfer to admin account minus fee',
        }, {
          stripe_account: current_user.stripe_account_id,
        })
        Payout.create(
          user: current_user,
          stripe_account_id: current_user.stripe_account_id,
          stripe_payout_id: payout.id,
          status_name: payout.status,
          executed_at: Time.at(payout.created).to_datetime,
          amount: @amount_to_transfer,
          fee: 200,
          total_deduction: @amount_to_transfer + 200,
        )
      end
      flash.notice = "#{@amount_to_transfer}円を入金しました"
      redirect_to user_payouts_path
    rescue ProfitMismatchError => e
      @error_message = e.message
      render "user/payouts/index", layout: "small"
    end
  end
end
