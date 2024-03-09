class Sample::Base < ApplicationController
    before_action :set_default_values
    before_action :check_meta_tag
    def set_default_values
        transaction_description = "これは回答のサンプルです。\r\nここに回答の内容が表示されます。\r\n質問に回答して報酬を手に入れよう！\r\nまた、質問箱のようにシェアできるのでシェアしよう！\r\nサービスによっては動画や画像を添付することもできます。"
        @request_description = "ここに相談内容が表示されます。\r\n・何に悩んでいるか\r\n・どうなりたいか\r\nなどを自由に記載して相談しよう！\r\nサービスによっては動画や画像を添付することもできます。"
        transaction_message_body1 =  "ここで追加で質問できます。\r\n分からないことや聞きそびれたことなどを追加で質問しよう！\r\n追加質問の受付期間はサービス毎に違うので注意しよう！"
        transaction_message_body2 =  "ここでは追加で回答できます。\r\n追加質問に対しての答えや、言いそびれたことなどを投稿しよう！"
        user_description =  "ここに自己紹介が表示されます。\r\n自身の経歴や得意分野について自由に記載できます。"
        @seller = User.new(
            id:0,
            name: "ユーザー名１",
            description: user_description,
            last_login_at: DateTime.now
          )
        @buyer = User.new(
            id:0,
            name: "ユーザー名２"
            )
        @service = Service.new(
            id:0,
            user:@seller,
            title:"サービスのタイトル",
            price:100,
            delivery_days:3,
            request_max_characters:1000,
            delivery_form:Form.find_by(name:"text"),
            request_form: Form.find_by(name:"text"),
            )
        @request = Request.new(
            id:0,
            user: @buyer,
            title:"質問のタイトル",
            description: @request_description,
            suggestion_deadline: DateTime.now,
            request_form: Form.find_by(name:"text"),
            delivery_form: Form.find_by(name:"text"),
            published_at:DateTime.now
            )
        @request_item = RequestItem.new(
            id:0,
            request:@request,
            thumbnail:"https://corretech0625.s3.amazonaws.com/uploads/request/file/1/description_image202301222712.png",
            file:"https://corretech0625.s3.amazonaws.com/uploads/request/file/1/description_image202301222712.png"
            )
        
        @request.thumbnail = @request_item.thumbnail
        @request.file = @request_item.file
        @request.set_item_values

        @transaction_message1 = TransactionMessage.new(
            created_at: DateTime.now,
            sender:@buyer,
            body:transaction_message_body1,
        )

        @transaction_message2 = TransactionMessage.new(
            created_at: DateTime.now,
            sender:@seller,
            body:transaction_message_body2,
        )
        @transaction_messages = [@transaction_message1, @transaction_message2]

        @delivery_item = DeliveryItem.new(
            deal:@transaction,
            thumbnail:"https://corretech0625.s3.amazonaws.com/uploads/transaction/file/1/description_image2023018132835.png",
            file:"https://corretech0625.s3.amazonaws.com/uploads/transaction/file/1/description_image2023018132835.png"
            )
        @transaction = Transaction.new(
            id:0,
            title:"回答のタイトル",
            request:@request,
            service:@service,
            delivered_at: DateTime.now,
            delivery_form:Form.find_by(name:"image")
            )
        @transaction.set_item
        @transaction.file = @delivery_item.file
        @transaction.thumbnail = @delivery_item.thumbnail
        @post = Post.new(body:"ここに投稿が表示されます。")
        @requests = [@request]
        @services = [@service]
        @requests = [@request]
        @posts = [@post]
        

        @transactions = [@transaction]
    end

    def check_meta_tag
        @twitter_title = "コレテク　~ノウハウを売買するQAサイト~"
        @twitter_site = "@3UJVrqxCS0V4bin"
        @twitter_creator = "@3UJVrqxCS0V4bin"
        @og_title = "コレテク　~ノウハウを売買するQAサイト~"
        @og_url = "https://corre-tech.com"
        @og_description = "コレテクとは質問や相談をし合うスキルシェアサービスです。相談内容は公開され、誰でも閲覧できるのが特徴！登録して悩みを相談しよう！"
        @og_site_name = "コレテク"
        @og_image  = "https://corre-tech.com/corretech_large_icon.png"
    end
end