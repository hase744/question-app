class SampleData
  CATEGORIES = ['business', 'career']
  def self.create_users
    Category.where(name: CATEGORIES).each do |category|
      file_path = Rails.root.join('public', 'sample', category.name, 'users.json')
      users = JSON.parse(File.read(file_path))
      Parallel.each(0..9) do |n|
        begin
        image_path = Rails.root.join('public', 'sample', "#{users[n]['image']}.jpg")
        header_image_path = Rails.root.join('public', 'sample', "header_image (#{n}).jpg")
        user = User.find_by(email: "seller#{category.name}#{n}@exmaple.com")
        user = User.create!(
          email: "seller#{category.name}#{n}@exmaple.com",
          name: users[n]['name'],
          image: File.open(image_path),
          header_image: File.open(header_image_path),
          password: "password",
          confirmed_at: Time.now,
          is_seller: true,
          is_dammy: true,
          #categories: categories[n%3],
          description: users[n]['description'],
          last_login_at:DateTime.now
        ) if !user.present?
        puts "売主 #{user.present?}"
        user.user_categories.create(category_name: category.name)

        user = User.find_by(email: "buyer#{category.name}#{n}@exmaple.com")
        user = User.create!(
          email: "buyer#{category.name}#{n}@exmaple.com",
          name: users[n]['name'],
          password: "password",
          confirmed_at: Time.now,
          is_seller: false,
          is_dammy: true,
          #categories: categories[n%3],
          description: users[n]['description'],
          last_login_at:DateTime.now
        ) if !user.present?
        puts "買手 #{user.present?}"
        #user = User.find_by(email: "buyer#{n}@exmaple.com") if !user.present?
        user.user_categories.create(category_name: category.name)
        rescue => e
          puts e
        end
      end
    end
  end

  def self.create_services
    Category.where(name: CATEGORIES).each do |category|
      file_path = Rails.root.join('public', 'sample', category.name, 'services.json')
      services = JSON.parse(File.read(file_path))
      #10.times do |n|
      Parallel.each(0..9) do |n|
        service_image_path = Rails.root.join('public', 'sample', "service_image(#{n}).png")
        service = Service.create_or_find_by!(
          user: User.find_by(email: "seller#{category.name}#{n}@exmaple.com"),
          title: services[n]['title'],
          description: services[n]['description'],
          price: (n+1)*100,
          category_id: category.id,
          stock_quantity: n + 1,
          transaction_message_days: n%30,
          delivery_days: n%14 + 1,
          request_form_name: Form.find_by(name: 'text').name_sym,
          delivery_form_name: Form.find_by(name: 'text').name_sym,
          request_max_characters: (n+1)*200,
          request_max_minutes: n,
          request_max_files: 0,
          image: File.open(service_image_path)
        )
        service.service_categories.create(category_name: category.name)
      end
    end
  end

  def self.create_requests
    Category.where(name: CATEGORIES).each do |category|
      file_path = Rails.root.join('public', 'sample', category.name, 'transactions.json')
      transactions = JSON.parse(File.read(file_path))
      #10.times do |n|
      Parallel.each(0..9) do |n|
        image_path = Rails.root.join('public', 'sample', category.name, "canvas (#{n}).jpg")
        if File.exist?(image_path)
          request = Request.create_or_find_by!(
            user: User.find_by(email: "buyer#{category.name}#{n}@exmaple.com"),
            title: transactions[n]['question']['title'],
            description: transactions[n]['question']['description'],
            max_price: (n+2)*500,
            mini_price: (n+1)*500,
            use_youtube:false,
            suggestion_deadline: DateTime.now + n + 1,
            request_form_name: Form.find_by(name:"text").name.to_sym,
            delivery_form_name: Form.find_by(name:"text").name.to_sym,
            total_services: 0,
            is_published: false,
            published_at:DateTime.now - n + 2,
            total_views:0,
            is_inclusive: true
          )
          request.request_categories.create(category_name: category.name)
          request.items.create(
            file: File.open(image_path),
          )
          request.update(is_published: true)
        else
          # ファイルが存在しない場合の処理
          puts "ファイルが見つかりません: #{file_path}"
        end
      end
    end
  end

  def self.create_transactions
    Category.where(name: CATEGORIES).each do |category|
      file_path = Rails.root.join('public', 'sample', category.name, 'transactions.json')
      transactions = JSON.parse(File.read(file_path))
      file_path = Rails.root.join('public', 'sample', category.name, 'services.json')
      services = JSON.parse(File.read(file_path))
      Parallel.each(0..9) do |n|
      #for n in 0..9
        image_path = Rails.root.join('public', 'sample', category.name, "canvas (#{n}).jpg")
        buyers = User.where(is_seller: false)
        sellers = User.where(is_seller: true)
        buyer = buyers[n%buyers.count]
        seller = User.find_by(email: "seller#{category.name}#{n}@exmaple.com")
        request = Request.create_or_find_by!(
          user: buyer,
          title: transactions[n]['question']['title'],
          description: transactions[n]['question']['description'],
          max_price: (n+2)*500,
          mini_price: (n+1)*500,
          use_youtube:false,
          suggestion_deadline: DateTime.now + n + 1,
          request_form_name: Form.find_by(name:"text").name.to_sym,
          delivery_form_name: Form.find_by(name:"text").name.to_sym,
          total_services: 0,
          is_published: false,
          published_at:DateTime.now - n + 2,
          total_views:0,
          is_inclusive: false
        )
        request.request_categories.create(category_name: category.name)
        request.items.create(
          file: File.open(image_path),
        )
        request.update(is_published: true)
        puts "seller#{n}@exmaple.com"
        service = Service.create_or_find_by!(
          user: seller,
          title: services[n]['title'],
          description: services[n]['description'],
          price: (n+1)*100,
          stock_quantity: n + 1,
          transaction_message_days: n%14+1,
          delivery_days: n%14 + 1,
          request_form_name: Form.find_by(name: 'text').name_sym,
          delivery_form_name: Form.find_by(name: 'text').name_sym,
          request_max_characters: (n+1)*50,
          request_max_minutes: n,
          request_max_files: 0,
        )
        service.service_categories.create(category_name: category.name)
        transaction = Transaction.create_or_find_by!(
          title: transactions[n]['answer']['title'],
          description: transactions[n]['answer']['description'],
          buyer: buyer,
          service: service,
          request: request,
          is_contracted:true,
          contracted_at:DateTime.now,
          is_delivered:true,
          delivered_at: DateTime.now - n,
          stripe_payment_id:"pi_3LO0pXFsZJRtLc1j0OJU7Mlg",
          use_youtube:true,
          youtube_id: nil,
          transaction_message_days: service.transaction_message_days,
          star_rating: n%6,
          review_description: "レビュー内容をここに表示",
          reviewed_at: DateTime.now - n,
          is_published:false
        )
        transaction.transaction_categories.create(category_name: category.name)
        for i in 0..5
          transaction_message = TransactionMessage.create_or_find_by!(
            deal: transaction,
            sender: buyer,
            receiver: seller,
            body: transactions[n]['additional_chat'][i*2]["question"],
          )
          transaction_message = TransactionMessage.create_or_find_by!(
            deal: transaction,
            sender: seller,
            receiver: buyer,
            body: transactions[n]['additional_chat'][i*2+1]["answer"],
          )
        end
      end
    end
  end
end