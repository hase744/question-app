class User::CardsController < User::Base
  layout "small"
  before_action :check_login
  before_action :check_card_unregistered, only:[:new, :create]
  before_action :check_card_registered, only:[:edit, :update, :destroy]

  def show
    @card = nil
    if current_user.stripe_card_id.present? && current_user.stripe_customer_id.present?
      @card = Stripe::Customer.retrieve_source(
        current_user.stripe_customer_id,
        current_user.stripe_card_id,
      )
    end
  end

  def new
    # あらかじめ環境変数に入れておいたテスト用公開鍵を、gonの変数にセット
    key = ENV['STRIPE_PUBLISHABLE_KEY']
    current_user = User.find_by(id:1)
  end

  def create
    # トークンが生成されていなかった場合は何もせずリダイレクト
    if params['stripeToken'].blank?
      redirect_to user_cards_path
    else
      # 送金元ユーザのStripeアカウントを生成
      sender = Stripe::Customer.create({
          # nameとemailは必須ではないが分かりやすくするために載せている
          name: current_user.name,
          email: current_user.email,
          source: params['stripeToken']
        })

      if sender
        # Cardテーブルに送金元ユーザのこのアプリでのIDと、StripeアカウントでのIDを保存
        puts sender
        @user = current_user
        @user.stripe_card_id = sender.default_source
        @user.stripe_customer_id = sender.id
        if @user.save
          redirect_to  user_cards_path
          flash.notice = "クレジットカードを登録しました。"
        else
          flash.notice = "クレジットカード登録に失敗しました。"
          redirect_to new_user_cards_path
        end
      else
        flash.notice = "クレジットカード登録に失敗しました。"
        redirect_to new_user_cards_path
      end
    end
  end

  def edit
  end
  
  def update
    # トークンが生成されていなかった場合は何もせずリダイレクト
    if params['stripeToken'].blank?
      redirect_to user_cards_path
    else
      sender = Stripe::Customer.update(
          # nameとemailは必須ではないが分かりやすくするために載せている
          current_user.stripe_customer_id,
          {source: params['stripeToken']},
        )
      
      if sender
        @user = current_user
        @user.stripe_card_id = sender.default_source
        @user.stripe_customer_id = sender.id
        if @user.save
          flash.notice = "クレジットカード情報を更新しました。"
          redirect_to  user_cards_path
        else
          flash.notice = "クレジットカード情報を更新できませんでした。"
          redirect_to new_user_cards_path
        end
      else
        flash.notice = "クレジットカード情報を更新できませんでした。"
        redirect_to new_user_cards_path
      end
    end
  end

  def destroy
    delete_info = Stripe::Customer.delete_source(
        current_user.stripe_customer_id,
        current_user.stripe_card_id
      )
    if delete_info.deleted
      current_user.update(stripe_card_id:nil)
      flash.notice = "クレジットカード情報を削除しました。"
    else
      flash.notice = "クレジットカード情報を削除できませんでした。"
    end
    redirect_to user_cards_path
  end

  def delete
    if current_user.update(stripe_card_id:nil)
      flash.notice = "クレジットカード情報を削除しました。"
    else
      flash.notice = "クレジットカード情報を削除できませんでした。"
    end
    redirect_to user_cards_path
  end

  private def check_card_unregistered
    if current_user.stripe_card_id.present?
      redirect_to user_configs_path
    end
  end

  private def check_card_registered
    if !current_user.stripe_card_id.present?
      redirect_to user_configs_path
    end
  end
end
