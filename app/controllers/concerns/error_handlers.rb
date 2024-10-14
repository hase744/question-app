module ErrorHandlers
  extend ActiveSupport::Concern

included do
  rescue_from StandardError, with: :rescue500
  rescue_from ProfitMismatchError, with: :profit_mismatch_rescue
  rescue_from NonZeroBalanceError, with: :no_zero_balance_rescue
  rescue_from ZeroTransferAmountError, with: :zero_transfer_amount_rescue
  rescue_from ApplicationController::Forbidden, with: :rescue403
  rescue_from ApplicationController::IpAdressRejected, with: :rescue403
  rescue_from ActiveRecord::RecordNotFound, with: :rescue404
  rescue_from ActionController::RoutingError, with: :rescue404
  rescue_from ActionController::ParameterMissing, with: :rescue400
  rescue_from Stripe::CardError, with: :stripe_card_rescue
  rescue_from Stripe::RateLimitError, with: :stripe_rate_limit_rescue
  rescue_from Stripe::InvalidRequestError, with: :stripe_invalid_request_rescue
  rescue_from Stripe::AuthenticationError, with: :stripe_authentication_rescue
  rescue_from Stripe::APIConnectionError, with: :stripe_api_connection_rescue
  rescue_from Stripe::StripeError, with: :stripe_rescue
end

  private def rescue400(e)
    @error = e
    create_error_log(e)
    render "errors/bad_request", status:  400, layout: "alert"
  end

  private def rescue403(e)
    @error = e
    create_error_log(e)
    render "errors/forbidden", status: 403, layout: "alert"
  end

  def rescue404
    render "errors/not_found", status: 404, layout: "alert"
  end

  private def rescue500(e)
    @error = e
    create_error_log(e)
    render "errors/internal_server_error", status: 500, layout: "alert"
  end

  private def stripe_card_rescue(e)
    @error = e
    @message = "クレジットカード認証に失敗しました。"
    create_error_log(e)
    render "errors/stripe_card_error", status: 500, layout: "alert"
  end

  private def stripe_rate_limit_rescue(e)
    @error = e
    @message = "アクセスが集中したため更新できませんでした。"
    create_error_log(e)
    render "errors/stripe_error", status: 500, layout: "alert"
  end

  private def stripe_invalid_request_rescue(e)
    @error = e
    @message = "不正なリクエストです。\n#{e}"
    create_error_log(e)
    render "errors/stripe_error", status: 500, layout: "alert"
  end

  private def stripe_authentication_rescue(e)
    @error = e
    @message = "権限がありません。"
    create_error_log(e)
    render "errors/stripe_error", status: 500, layout: "alert"
  end

  private def stripe_api_connection_rescue(e)
    @error = e
    @message = "接続に失敗しました。"
    create_error_log(e)
    render "errors/stripe_error", status: 500, layout: "alert"
  end

  private def stripe_rescue(e)
    @error = e
    @message = "決済情報のエラーです。\n#{e}"
    create_error_log(e)
    render "errors/stripe_error", status: 500, layout: "alert"
  end

  private def profit_mismatch_rescue(e)
    @error = e
    @message = "Profit and available amount mismatch: #{e.message}"
    create_error_log(e)
    #render "errors/profit_mismatch", status: 500, layout: "alert"
  end

  private def no_zero_balance_rescue(e)
    @error = e
    @message = "Non zero balance error: #{e.message}"
    create_error_log(e)
  end

  private def zero_transfer_amount_rescue(e)
    @error = e
    @message = "There is insufficient amount to to transfer: #{e.message}"
    create_error_log(e)
  end
end