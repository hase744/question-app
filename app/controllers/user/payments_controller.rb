class User::PaymentsController < User::Base
  layout "small"
  before_action :check_login, only:[:index, :create]
  before_action :check_stripe_customer
  before_action :display_payment_message
  def index
    @payments = current_user.payments
      .order(executed_at: :desc)
      .page(params[:page])
      .per(50)
    @payment = Payment.new(point: params[:point].presence || 100)
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def secret
    return if request.request_method == 'PUT'
    @payment = current_user.payments.new(payment_params)
    intent = Stripe::PaymentIntent.create({
      customer: current_user.stripe_customer_id,
      payment_method: current_user.stripe_card_id,
      amount: @payment.value,
      currency: 'jpy',
      setup_future_usage: 'off_session',
      payment_method_types: ['card'],
    })
    @payment.stripe_payment_id = intent['id']
    @payment.status = intent['status']
    @payment.executed_at = Time.at(intent.created).to_datetime
    if @payment.save
      render json: { client_secret: intent['client_secret'], id: @payment.id }
    else
      puts @payment.errors.full_messages
    end
  end

  def check
    @payment = current_user.payments.find(params[:id])
    intent = Stripe::PaymentIntent.retrieve(@payment.stripe_payment_id)
    @payment.status = intent.status
    if @payment.save && intent.status == "succeeded"
      session[:message] = "#{@payment.value}pチャージしました"
      flash.notice = "#{@payment.value}pチャージしました"
      redirect_back(fallback_location: root_path)
    else
      flash.notice = "チャージに失敗しました。"
    end
  end

  def create
    @payment = Payment.new(payment_params)

    #charge = Stripe::Charge.create({
    #  amount: @payment.value,
    #  currency: "jpy", # 請求通貨は円で固定していますが変更可能です
    #  customer: current_user.stripe_customer_id,
    #})

    @payment.user = current_user
    #@payment.stripe_payment_id = charge.id #id
    @payment.status = charge.status #ステータス
    @payment.executed_at = Time.at(charge.created).to_datetime
    @payment.save
    if charge.status == "succeeded"
      flash.notice = "#{@payment.value}pチャージしました"
    else
      flash.notice = "チャージできません"
    end
    redirect_back(fallback_location: root_path)
  end

  def payment_params
    params.require(:payment).permit(
      :value,
      :point
    )
  end
end
