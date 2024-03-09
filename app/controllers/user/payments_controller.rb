class User::PaymentsController < User::Base
    layout "small"
    before_action :check_login, only:[:show, :create]
    before_action :check_stripe_customer
    def show
        @point = current_user.total_points
        @payments = current_user.payments
        @controller_name = params[:controller_name]
        @action_name = params[:action_name]
        @id_number = params[:id_number]
        @service_id = params[:service_id]
        

        @payment = Payment.new()
        @hash = {} #セレクトタグに使うハッシュ
        if params[:price]
            @default_point = params[:price]
        else
            @default_point = 100
        end
        @hash.store("#{@default_point}p","#{@default_point}")
        
        100.times do  |n|#ハッシュにポイントと金額を加える
            point = 100*(n+1)
            if point != @default_point
                @hash.store("#{point}p", "#{point}")
            end
        end
    end

    def create
        @payment = Payment.new(payment_params)
        path = Rails.application.routes.generate_extras({:controller=>params[:controller], :action=>params[:action], :id=>params[:id_number]})

        charge = Stripe::Charge.create({
          amount: @payment.price,
          currency: "jpy", # 請求通貨は円で固定していますが変更可能です
          customer: current_user.stripe_customer_id,
        })

        #payment = Stripe::PaymentIntent.create({
        #    amount: @payment.price,
        #    currency: 'jpy',
        #    payment_method_types: ['card'],
        #    customer: current_user.stripe_customer_id,
        #    payment_method: current_user.stripe_card_id,
        #    confirm:false,
        #    application_fee_amount: @payment.price,
        #    transfer_data: {
        #          amount: 0,
        #          destination: User.first.stripe_account_id,
        #          }
        #  })
        #  puts payment
        @payment.user = current_user
        @payment.stripe_payment_id = charge.id #id
        @payment.status = charge.status #ステータス
        @payment.save
        if charge.status == "succeeded"
            flash.notice = "#{@payment.price}pチャージしました"
            puts "チャージ"
            begin
                @controller_name = params[:payment][:controller_name]
                @action_name = params[:payment][:action_name]
                @id_number = params[:payment][:id_number]
                @service_id = params[:payment][:service_id]
                path = Rails.application.routes.generate_extras({:controller=>@controller_name, :action=>@action_name, :id=>@id_number})
                if params[:payment][:service_id]
                    puts "パラメーター"
                    redirect_to new_user_request_path(service_id:@service_id)
                else
                    redirect_to new_user_request_path
                end
            rescue
                redirect_to user_configs_path
            end
        else
            flash.notice = "チャージできません"
            redirect_back(fallback_location: root_path)
        end
        #puts charge
    end

    def payment_params
        params.require(:payment).permit(
            :price,
            :point
        )
    end
end
