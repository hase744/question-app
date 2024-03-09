class User::ConnectsController < User::Base
  layout "small", only:[:edit]
  before_action :check_login
  before_action :phone_valid?, only:[:update, :edit]
  before_action :check_connect_unregistered, only:[:new, :create, :certify_phone]
  before_action :check_connect_registered, only:[:update, :destroy]
  before_action :check_ongoing_transaction, only:[:destroy]
  before_action :check_phone_confirmation_enabled, only:[:certify_phone, :create, :new, :send_token]

  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  def show
    @account = nil
    if current_user.stripe_account_id
      @account = Stripe::Account.retrieve(current_user.stripe_account_id)
      puts @account
    end
    puts request.url.to_s.gsub(/connects/,"accounts/#{current_user.id}").to_s
  end

  def register_as_seller
    current_user.is_seller = true
  end

  def new
    if current_user.phone_confirmed_at.present?
      redirect_to edit_user_connects_path
    end
    define_countryies
  end

  def certify_phone
    if request.post?
      @user = current_user
      if can_phone_confirm
        @user.phone_number = params[:certification_number]
        @user.country_id = params[:country_id]
        send_confirmation_token
      else
        puts "現在認証ができません"
        flash.notice = "#{@user.phone_confirmation_enabled_at.strftime('%Y/%m/%d %H:%M:%S')}まで認証ができません。"
        redirect_to new_user_connects_path
      end
    end

    if request.get?
    end
  end

  def send_token
    flash.notice = "認証コードを送信しました。"
    send_confirmation_token
  end

  def alert
    @user = current_user
    if current_user.phone_confirmation_enabled_at < DateTime.now
      redirect_to user_connects_path
    end
  end

  def create
    @user = current_user
    puts "裏付け"
    puts can_phone_confirm
    if can_phone_confirm
      if @user.phone_confirmation_token == params[:phone_confirmation_token]
        @user.phone_confirmed_at = DateTime.now
        if @user.save 
          flash.notice = "電話番号を登録しました。"
          redirect_to edit_user_connects_path
        end
      else
        flash.notice = "番号が違います。"
        @user.total_phone_confirmation_attempts += 1
        if @user.total_phone_confirmation_attempts < 5 || @user.total_phone_confirmation_attempts%5 != 0
        elsif @user.total_phone_confirmation_attempts == 5
          @user.phone_confirmation_enabled_at = DateTime.now + Rational(1, 24)
        elsif @user.total_phone_confirmation_attempts == 10
          @user.phone_confirmation_enabled_at = DateTime.now + 1
        elsif @user.total_phone_confirmation_attempts >= 20
          @user.phone_confirmation_enabled_at = DateTime.now + 7
        end
        @user.save
        redirect_to user_get_certify_phone_path
      end
    else
      flash.notice = "#{from_now(@user.phone_confirmation_enabled_at)}まで認証ができません。"
      redirect_to user_get_certify_phone_path
    end
  end

  def can_phone_confirm
    if @user.phone_confirmation_enabled_at == nil
      true
    else
      @user.phone_confirmation_enabled_at < DateTime.now
    end
  end

  def destroy
    begin
      response = Stripe::Account.delete(current_user.stripe_account_id)
      puts response
      if response.deleted == true && current_user.update(stripe_account_id:nil, is_seller:false)
        flash.notice = "振り込め先情報を削除しました。"
      else
        flash.notice = "振り込め先情報を削除できませんでした。"
      end
    rescue
      puts "エラー"
      flash.notice = "振り込め先情報を削除できませんでした。"
    end
    redirect_to user_connects_path
  end

  def edit
    @user = current_user
    if current_user.stripe_account_id
      @account = Stripe::Account.retrieve(current_user.stripe_account_id)
      @birth_dat = nil
      @address_kana = nil
      @address_kanji = nil
      @bank_account = nil
      if defined?(@account.individual)
        puts "個人情報あり"
        @birth_date = @account.individual["dob"]
        @address_kana = @account.individual["address_kana"]
        @address_kanji = @account.individual["address_kanji"]
        @bank_account = @account.external_accounts["data"][0]
      end
      puts "個人情報"
      puts @account
    else
      puts "個人情報なし"
      new_account = Stripe::Account.create(
          country: 'jp',
          type: 'custom',
          email: @user.email,
          business_type: "individual",
          capabilities: {
              card_payments: {requested: true},
              transfers: {requested: true},
              legacy_payments:{requested: true},
              },
          )
      @user.stripe_account_id = new_account["id"] 
      @user.save   
    end
    #if Rails.env.development?
    #  @account.individual = development_individual
    #  @birth_date = development_individual["dob"]
    #  @address_kana = development_individual["address_kana"]
    #  @address_kanji = development_individual["address_kanji"]
    #  @bank_account = development_individual["external_accounts"]
    #end
    set_edit_value
  end

  def set_edit_value
    if Rails.env.development?
      @user.last_name_kanji = ENV["LAST_NAME_KANJI"]
      @user.last_name_kana = ENV["LAST_NAME_KANA"]
      @user.first_name_kanji =  ENV["FIRST_NAME_KANJI"]
      @user.first_name_kana =  ENV["FIRST_NAME_KANA"]
      @user.gender = "male"
      @user.is_male = true
      @user.is_female = false
      @user.state_kanji =  ENV["STATE_ADDRESS_KANJI"]
      @user.state_kana = ENV["STATE_KANA"]
      @user.city_kanji =  ENV["CITY_ADDRESS_KANJI"]
      @user.city_kana =  ENV["CITY_KANA"]
      @user.town_kanji =  ENV["TOWN_ADDRESS_KANJI"]
      @user.town_kana =  ENV["TOWN_KANA"]
      @user.line1_kanji = ENV["LINE1_ADDRESS_KANJI"]
      @user.line2_kanji = ENV["LINE1_ADDRESS_KANJI"]
      @user.line2_kana = ENV["LINE2_KANA"]
      @user.birth_date = Date.new(2000, 04, 9)
      @user.postal_code = "1620835"
      @user.account_number = "5467253"
      @user.bank_number = "0017"
      @user.branch_number = "364"
      @user.account_holder_name = "Ko Hasegawa"
    elsif defined?(@account.individual)# || Rails.env.development? 
      @user.last_name_kanji = @account.individual["last_name_kanji"]
      @user.last_name_kana = @account.individual["last_name_kana"]
      @user.first_name_kanji =  @account.individual["first_name_kanji"]
      @user.first_name_kana =  @account.individual["first_name_kana"]
      @user.state_kanji =  @address_kanji["state"]
      @user.state_kana =  @address_kana["state"]
      @user.city_kanji =  @address_kanji["city"]
      @user.city_kana =  @address_kana["city"]
      @user.town_kanji =  @address_kanji["town"]
      @user.town_kana =  @address_kana["town"]
      @user.line1_kanji = @address_kanji["line1"]
      @user.line2_kanji = @address_kanji["line2"]
      @user.line2_kana = en_to_em(@address_kana["line2"])
      @user.birth_date = Date.new(@birth_date["year"], @birth_date["month"], @birth_date["day"])
      @user.postal_code = @address_kana["postal_code"][0..2]+"-"+@address_kana["postal_code"][3..6]
      @user.bank_number = @bank_account["routing_number"][0..3]
      @user.branch_number = @bank_account["routing_number"][4..7]
      
      puts "初期値"
      puts "口座番号"
    @user.bank_number
    end
  end

  def update
    str_today = "2018-12-05"    # 文字列型の日付（変換前） 
    str_today.to_date    # Date型の日付（変換後）
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    puts params[:file]
    
    file = File.new(params[:user][:certification])
    @stripe_file = nil
    if current_user.stripe_account_id
      @stripe_file = create_stripe_file(file)
      puts @stripe_file
    end

    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    if Rails.env == "development"
      url = "https://twitter.com/hase97531"
    else
      url = request.url.to_s.gsub(/connects/,"accounts/#{current_user.id}").to_s
    end
    @user_params = params[:user]
    @user = current_user
    @user.assign_attributes(user_params)

    account = Stripe::Account.update(
            current_user.stripe_account_id,
            {
            tos_acceptance: {date: Time.parse(Date.today.to_s).to_i, ip: '8.8.8.8'},
            business_profile:business_profile_hash,
            business_type: "individual",
            email: current_user.email,
            external_account:external_accounts_hash,
            individual:individual_hash,
            capabilities: {
                card_payments: {requested: true},
                transfers: {requested: true},
                },
            })
    puts account
    if account
      if current_user.save
        flash.notice = "振込先情報が登録されました。承認までしばらくお待ちください。"
        redirect_to user_configs_path
      else
        flash.notice = "振込先情報が登録できませんでした。"
        render = "user/connects/edit"
      end
    else
      puts "accountなし"
      @error += "エラーID:#{@error_log.id}<br>"
      @error += "<br>以上を運営まで連絡してください"
      flash.notice = "エラーが潰瘍しない場合、更新したい場合はエラーIDとともに運営までご連絡してください。"
      redirect_to edit_user_connects_path(error: @error)
    end
  end

  def create_stripe_file(file)
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    Stripe::File.create({
        purpose: 'identity_document',
        file: file,
        }, {
        stripe_account: current_user.stripe_account_id,
        })
  end

  def business_profile_hash
    if Rails.env == "production"
    {
      mcc: "5815",
      name: nil,
      product_description: "依頼者の悩みに応える。",
      support_address: nil,
      support_email: nil,
      support_phone: "+#{current_user.country.code}#{current_user.phone_number}",
      support_url: nil,
      url: request.url.to_s.gsub(/connects/,"accounts/#{current_user.id}").to_s
    }
    else
    {
      mcc: "5815",
      name: ENV["LAST_NAME_KANA"],
      product_description: "依頼者の悩みに応える。",
      support_address: nil,
      support_email: current_user.email,
      support_phone: "+#{current_user.country.code}#{current_user.phone_number}",
      support_url: nil,
      url: "https://twitter.com/hase97531"
    }
    end
  end

  def external_accounts_hash
    if true
    {
    object: "bank_account",
    country: "jp",
    currency: "jpy",
    account_number: @user.account_number,
    routing_number: "#{@user.bank_number}-#{@user.branch_number}",
    account_holder_name: @user.account_holder_name,
    #account_holder_type: nil,
    }
    else
    {
    object: "bank_account",
    country: "jp",
    currency: "jpy",
    account_number: @user.account_number,
    routing_number: "000123456789",
    account_holder_name: @user.account_holder_name,
    #account_holder_type: nil,
    }
    end
  end

  def individual_hash
    puts "パラメーター"
    puts @user.city_kana
    {
    address_kana: {
    city: half_size_kana(@user.city_kana),
    country: "JP",
    line1: @user.line1_kanji,
    line2: half_size_kana(@user.line2_kana),
    postal_code: @user.postal_code,
    state: half_size_kana(@user.state_kana),
    town: half_size_kana(@user.town_kana)
    },
    address_kanji: {
    city: @user.city_kanji,
    country: "JP",
    line1: @user.line1_kanji,
    line2: @user.line2_kanji,
    postal_code: @user.postal_code,#一様半角
    state: @user.state_kanji,
    town: @user.town_kanji
    },
    dob: {
      day: @user.birth_date.to_date.day,
      month: @user.birth_date.to_date.month,
      year: @user.birth_date.to_date.year
    },
    email: current_user.email,
    first_name: @user.first_name_kanji,
    first_name_kana: @user.first_name_kana,
    first_name_kanji: @user.first_name_kanji,
    gender: @user.gender,
    last_name:  @user.last_name_kanji,
    last_name_kana: @user.last_name_kana,
    last_name_kanji: @user.last_name_kanji,
    metadata: {},
    phone: "+#{current_user.country.code}#{current_user.phone_number}",
    verification: {
        additional_document: {
           back: nil,
           front: nil
           },
        document: {
            back: nil,
            front: @stripe_file["id"]
            },
        }
    }
  end

  def development_individual
    {
    "address_kana"=> {
    "city"=> half_size_kana(ENV["CITY_KANA"]),
    "country"=> "JP",
    "line1"=> ENV["LINE1_ADDRESS_KANJI"],
    "line2"=> ENV["LINE1_KANA"],
    "postal_code"=> ENV["POSTAL_CODE_KANA"],
    "state"=> half_size_kana(ENV["STATE_KANA"]),
    "town"=> half_size_kana(ENV["TOWN_KANA"])
    },
    "address_kanji"=> {
    "city"=> ENV["CITY_ADDRESS_KANJI"],
    "country"=> "JP",
    "line1"=> ENV["LINE1_ADDRESS_KANJI"],
    "line2"=> ENV["LINE1_ADDRESS_KANJI"],
    "postal_code"=> ENV["POSTAL_CODE_ADDRESS_KANJI"],
    "state"=> ENV["STATE_ADDRESS_KANJI"],
    "town"=> ENV["TOWN_ADDRESS_KANJI"]
    },
    "dob"=> {
      "day"=> 9,
      "month"=> 4,
      "year"=> 2000
    },
    "email"=> current_user.email,
    "first_name"=>  ENV["FIRST_NAME_KANJI"],
    "first_name_kana"=> ENV["FIRST_NAME_KANA"],
    "first_name_kanji"=> ENV["FIRST_NAME_KANJI"],
    "last_name"=> ENV["LAST_NAME_KANJI"],
    "last_name_kana"=> ENV["LAST_NAME_KANA"],
    "last_name_kanji"=> ENV["LAST_NAME_KANJI"],
    "gender"=> "male",
    "metadata"=> {},
    "phone"=> "+#{current_user.country.code}#{current_user.phone_number}",
    "external_accounts"=> {
      "routing_number" => "0017"
    }
    #verification"=> {
    #    additional_document"=> {
    #       back"=> nil,
    #       front"=> nil
    #       },
    #    document"=> {
    #        back"=> nil,
    #        front"=> @stripe_file["id"]
    #        },
    #    }
    }
  end

  def send_balance
    payout = Stripe::Payout.create({
      amount: 100,
      currency: 'jpy',
      description:'acct_1NSE5bFsS0WPuI4y',
    })
  end
  
  def send_confirmation_token
    account_sid = Rails.application.credentials.twilio[:account_sid]
    auth_token = Rails.application.credentials.twilio[:auth_token]
    token = rand(999999)
    @user.phone_confirmation_token = token
    @user.phone_confirmation_sent_at = DateTime.now
    if @user.save
      begin 
      @client = Twilio::REST::Client.new(account_sid, auth_token)
      message = @client.messages.create(
        body: "コレテクの認証コード：#{token}",
        to: "+#{@user.country.code}#{@user.phone_number}",    # Replace with your phone number
        from: "+19897188878"
      )  # Use this Magic Number for creating SMS
      puts "message.sid"
      puts message.sid
      redirect_to user_get_certify_phone_path
      rescue Twilio::REST::RestError => e
        flash.notice = "電話番号が見つかりません"
        redirect_to new_user_connects_path
      end
    else
      define_countryies
      puts "失敗"
      render "user/connects/new"
    end
  end

  private def define_countryies
    @countries_form = Country.all.map { |c| 
      ["#{c.japanese_name} +#{c.code}", c.name] 
    }.to_h
  end

  private def check_ongoing_transaction
    Transaction.where(seller:current_user ,is_delivered:false, is_canceled:false).each do |transaction|
      if !transaction.is_rejected
        flash.notice = "取引中の依頼があります。依頼を完了するか断って下さい。"
        redirect_to user_connects_path
        break
      end
    end
  end

  private def check_connect_unregistered
    if current_user.stripe_account_id.present?
      redirect_to user_connects_path
    end
  end
  
  private def check_connect_registered
    if !current_user.stripe_account_id.present?
      redirect_to user_connects_path
    end
  end

  private def phone_valid?
    if current_user.phone_confirmed_at.present?
    else
      redirect_to new_user_connects_path
    end
  end
  
  private def user_params
    params.require(:user).permit(
        :certification, 
        :last_name_kanji, 
        :last_name_kana,
        :first_name_kanji, 
        :first_name_kana,
        :gender,
        :state_kanji,
        :state_kana,
        :city_kanji,
        :city_kana,
        :town_kanji,
        :town_kana,
        :line1_kanji,
        :line2_kanji,
        :line2_kana,
        :birth_date,
        :postal_code,
        :bank_number,
        :branch_number,
        :account_number,
        :account_holder_name
    )
  end

  private def check_phone_confirmation_enabled
    @user = current_user
    if !can_phone_confirm
      flash.notice = "現在登録できません。"
      redirect_to user_connects_alert_path
    end
  end
end
