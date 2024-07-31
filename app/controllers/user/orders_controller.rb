class User::OrdersController < User::Base
  before_action :check_login
  before_action :identify_user, only:[:show, :edit, :update]
  before_action :identify_seller, only:[:show, :reject]
  before_action :check_transaction_is_editable, only:[:edit, :update]
  layout :choose_layout

  private def choose_layout
    case action_name
    when "show"
      "small"
    when "edit"
      "small"
    else
      "application"
    end
  end
  
  def index
    @transactions = Transaction.solve_n_plus_1
      .where.not(contracted_at: nil)
    @transactions = @transactions.page(params[:page]).per(10)
    #パラメーターが空の時、ユーザー情報からデフォルトとしてパラメーターを設定
    if !params[:user].present?
      if current_user.stripe_account_id.present?
        params[:user] = "seller"
        params[:scope] = "ongoing"
      else
        params[:user] = "buyer"
        params[:scope] = "ongoing"
      end
    end

    #
    if params[:user] == "buyer"
      @transactions = @transactions.where(
        request:{user:current_user}
      )
    else
      @transactions = @transactions.where(
        service:{user:current_user}
      )
    end
    
    if params[:scope] == "ongoing"
      @transactions = @transactions.ongoing
    elsif params[:scope] == "rejected"
      @transactions = @transactions.rejected
    elsif params[:scope] == "undelivered"
      @transactions = @transactions.undelivered
    else
      @transactions = @transactions.delivered
    end
  end

  def show
    @transaction = Transaction.find(params[:id])

    if @transaction.title && @transaction.description
      @disabled = false
    else
      @disabled = true
    end
    puts @disabled
    set_show_values
  end

  def edit
    @transaction = Transaction.left_joins(:service).find_by(id: params[:id], service: {user: current_user})
  end

  def cancel #依頼人がキャンセルするためのaction
    @transaction = Transaction.left_joins(:request).find_by(id:params[:id], request:{user: current_user})
    @request = @transaction.request
    @service = @transaction.service

    @transaction.assign_attributes(is_canceled: true, canceled_at: DateTime.now)
    #@service.stock_quantity = @service.stock_quantity+1 if @service.stock_quantity

    ActiveRecord::Base.transaction do
      if @transaction.save && @service.save && current_user.update_total_points
        flash.notice = "質問をキャンセルしました"
        redirect_to user_orders_path(user: "buyer", scope: "ongoing")
        create_cancel_notification
        EmailJob.perform_later(mode: :cancel, model: @transaction)
      else
        detect_models_errors([@transaction, current_user, @service])
        flash.alert = "キャンセルできませんでした"
        render "user/shared/error"
      end
    end
  end

  def reject #依頼を拒否する
    @transaction = Transaction.left_joins(:service).find_by(id:params[:id], service: {user: current_user})
    @service = @transaction.service
    @request = @transaction.request
    @buyer = @request.user

    @transaction.assign_attributes(reject_params)
    @transaction.rejected_at = DateTime.now
    #@service.stock_quantity = @service.stock_quantity+1 if @service.stock_quantity

    ActiveRecord::Base.transaction do
      if @request.save && @buyer.update_total_points && @service.save && @transaction.save 
        flash.notice = "質問を断りました"
        create_rejection_notification
        redirect_to user_orders_path(user: "seller", scope: "ongoing")
        EmailJob.perform_later(mode: :reject, model: @transaction)
      else
        gon.text_max_length = @transaction.reject_reason_max_length
        render "user/orders/edit"
      end
    end
  end

  def cancel_payment
    Stripe::PaymentIntent.cancel(
      @transaction.stripe_payment_id,
    )
  end
  
  def create_notification(request, user)
    Notification.create(
      user_id: user.id,
      notifier_id: current_user.id,
      description: "依頼が中断されました。",
      action: "show",
      controller: "requests",
      id_number: request.id
      )
  end

  def create_cancel_notification
    Notification.create(
      user_id: @transaction.seller,
      notifier_id: current_user.id,
      description: "依頼がキャンセルされました。",
      action: "index",
      controller: "orders",
      id_number: @request.id,
      parameter: "?scope=undelivered&user=seller"
      )
  end


  def create_rejection_notification
    Notification.create(
      user_id: @transaction.buyer.id,
      notifier_id: current_user.id,
      description: "質問がお断りされました。",
      action: "index",
      controller: "orders",
      id_number: @request.id,
      parameter: "?scope=undelivered&user=buyer"
      )
  end

  def check_transaction_is_editable
    @transaction = Transaction.find(params[:id])
    if !can_edit_transaction
      puts "その取引は編集できません"
      flash.notice = "その取引は編集できません"
      redirect_to user_orders_path
    end
  end

  def set_show_values
    gon.transaction_id = @transaction.id
    gon.delivery_form = @transaction.delivery_form.name
    gon.description = @transaction.description
    if @transaction.item
      if @transaction.file.url == nil 
        gon.is_file_nil = true
      else 
        gon.is_file_nil = false
      end
      if @transaction.description == nil 
        gon.is_transaction_description_nil = true
      else 
        gon.is_transaction_description_nil = false
      end
    end
  end

  private def can_edit_transaction
    if @transaction.is_canceled
      false
    elsif @transaction.is_rejected
      false
    elsif @transaction.is_delivered
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
      :is_rejected,
      :reject_reason
    )
  end

  private def transaction_params
    params.require(:transaction).permit(
      :is_canceled
    )
  end
end
