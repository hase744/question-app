class User::PaymentsController < User::Base
  layout "small"
  before_action :check_login, only:[:index, :create]
  before_action :check_stripe_customer
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

  def create
    @payment = Payment.new(payment_params)

    charge = Stripe::Charge.create({
      amount: @payment.value,
      currency: "jpy", # 請求通貨は円で固定していますが変更可能です
      customer: current_user.stripe_customer_id,
    })

    @payment.user = current_user
    @payment.stripe_payment_id = charge.id #id
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
