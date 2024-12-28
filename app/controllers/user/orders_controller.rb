class User::OrdersController < User::Base
  before_action :check_login
  before_action :identify_user, only:[:show, :edit, :update]
  before_action :identify_seller, only:[:reject]
  before_action :check_transaction_is_editable, only:[:edit, :update]
  layout :choose_layout

  private def choose_layout
    case action_name
    when "show"
      "small"
    when "edit"
      "small"
    when "reject"
      "small"
    else
      "application"
    end
  end
  
  def index
    @transactions = Transaction.solve_n_plus_1
      .where.not(contracted_at: nil)
      .order(contracted_at: :desc)
    @transactions = @transactions.page(params[:page]).per(10)
    #パラメーターが空の時、ユーザー情報からデフォルトとしてパラメーターを設定
    unless params[:user].present?
      if current_user.is_seller
        params[:user] = "seller"
        params[:scope] = "all"
      else
        params[:user] = "buyer"
        params[:scope] = "all"
      end
    end

    if params[:user] == "buyer"
      @transactions = @transactions.where(
        request:{user:current_user}
      )
    else
      @transactions = @transactions.where(
        service:{user:current_user}
      )
    end

    case params[:scope]
    when "all" then
      @transactions = @transactions
    when "ongoing" then
      @transactions = @transactions.ongoing
    when "rejected" then
      @transactions = @transactions.rejected
    when "delivered" then
      @transactions = @transactions.delivered
    when "undelivered" then
      @transactions = @transactions.undelivered
    end
  end

  def show
    @transaction = Transaction.find(params[:id])

    if @transaction.title && @transaction.description
      @disabled = false
    else
      @disabled = true
    end
  end

  def edit
    @transaction = Transaction.left_joins(:service).find_by(id: params[:id], service: {user: current_user})
  end

  def cancel #依頼人がキャンセルするためのaction
    @transaction = Transaction.left_joins(:request).find_by(id:params[:id], request:{user: current_user})
    @request = @transaction.request
    @service = @transaction.service
    @transaction.set_cansel

    ActiveRecord::Base.transaction do
      if save_models && @transaction.destroy_all_coupons
        flash.notice = "購入をキャンセルしました"
        redirect_to user_order_path(id: @transaction.id)
        create_cancel_notification
        EmailJob.perform_later(mode: :cancel, model: @transaction) if @transaction.seller.can_email_transaction
      else
        detect_models_errors([@transaction, current_user, @service])
        flash.alert = "キャンセルできませんでした"
        redirect_to user_order_path(@transaction.id)
      end
    end
  end

  def reject #依頼を拒否する
    @transaction = Transaction.left_joins(:service).find_by(id:params[:id], service: {user: current_user})
    @service = @transaction.service
    @request = @transaction.request
    @buyer = @request.user
    @transaction.assign_attributes(reject_params)
    @transaction.set_rejection

    ActiveRecord::Base.transaction do
      if save_models && @transaction.destroy_all_coupons
        flash.notice = "お断りの連絡を送信しました"
        create_rejection_notification
        redirect_to user_order_path(id: @transaction.id)
        EmailJob.perform_later(mode: :reject, model: @transaction) if @transaction.buyer.can_email_transaction
      else
        flash.notice = "お断りの連絡を送信できませんでした"
        render "user/orders/edit"
      end
    end
  end

  def cancel_payment
    Stripe::PaymentIntent.cancel(
      @transaction.stripe_payment_id,
    )
  end
  
  def create_cancel_notification
    Notification.create!(
      user_id: @transaction.seller.id,
      notifier_id: current_user.id,
      title: "購入がキャンセルされました",
      published_at: DateTime.now,
      action: "show",
      controller: "orders",
      id_number: @transaction.id,
      )
  end

  def create_rejection_notification
    Notification.create(
      user_id: @transaction.buyer.id,
      notifier_id: current_user.id,
      title: "回答がお断りされました",
      description: @transaction.reject_reason,
      published_at: DateTime.now,
      action: "show",
      controller: "orders",
      id_number: @transaction.id,
      )
  end

  def check_transaction_is_editable
    @transaction = Transaction.find(params[:id])
    if !can_edit_transaction
      flash.notice = "その取引は編集できません"
      redirect_to user_orders_path
    end
  end

  private def can_edit_transaction
    if @transaction.is_canceled
      false
    elsif @transaction.is_rejected
      false
    elsif @transaction.is_transacted
      false
    else
      true
    end
  end

  private def identify_user
    transaction =  Transaction.find(params[:id])
    if transaction.seller != current_user && transaction.buyer != current_user
      redirect_to user_orders_path
    end
  end

  private def identify_seller
    transaction =  Transaction.find(params[:id])
    if transaction.service.user != current_user
      redirect_to user_orders_path
    end
  end

  private def reject_params
    params.require(:transaction).permit(
      :reject_reason
    )
  end

  private def transaction_params
    params.require(:transaction).permit(
      :is_canceled
    )
  end
end
