class User::PaymentsController < User::Base
  layout "small"
  before_action :check_login, only:[:index, :create]
  before_action :check_stripe_customer
  def index
    @point = current_user.total_points
    @payments = current_user.payments
      .order(executed_at: :desc)
      .page(params[:page])
      .per(50)
    @payment = Payment.new()
    @hash = {} #セレクトタグに使うハッシュ
    if params[:point]
      @default_point = params[:point]
    else
      @default_point = 100
    end
    @hash.store("#{@default_point}p","#{@default_point}")
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def create
    @payment = Payment.new(payment_params)

    charge = Stripe::Charge.create({
      amount: @payment.value,
      currency: "jpy", # 請求通貨は円で固定していますが変更可能です
      customer: current_user.stripe_customer_id,
    })

    #payment = Stripe::PaymentIntent.create({
    #   amount: @payment.value,
    #   currency: 'jpy',
    #   payment_method_types: ['card'],
    #   customer: current_user.stripe_customer_id,
    #   payment_method: current_user.stripe_card_id,
    #   confirm:false,
    #   application_fee_amount: @payment.value,
    #   transfer_data: {
    #        amount: 0,
    #        destination: User.first.stripe_account_id,
    #        }
    #  })
    #  puts payment
    @payment.user = current_user
    @payment.stripe_payment_id = charge.id #id
    @payment.status = charge.status #ステータス
    @payment.executed_at = Time.at(charge.created).to_datetime
    @payment.save
    if charge.status == "succeeded"
      flash.notice = "#{@payment.value}pチャージしました"
      begin
        @service_id = session[:payment_service_id]
        @transaction_id = session[:payment_transaction_id]
        if @service_id && @transaction_id
          redirect_to user_service_path(@service_id, transaction_id: @transaction_id)
        elsif @service_id
          redirect_to new_user_request_path(service_id: @service_id)
        else
          redirect_to user_payments_path
        end
      rescue
        redirect_to user_payments_path
      end
    else
      flash.notice = "チャージできません"
      redirect_back(fallback_location: root_path)
    end
    #puts charge
  end

  def payment_params
    params.require(:payment).permit(
      :value,
      :point
    )
  end
end
