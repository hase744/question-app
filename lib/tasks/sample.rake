namespace :sample do
  desc "サンプルの生成" 
  task create_users: :environment do
    file_path = Rails.root.join('public','sample', 'users.json')
    users = JSON.parse(File.read(file_path))
    10.times do |n|
      begin
      image_path = Rails.root.join('public','sample', "#{users[n]['name']}.jpg")
      user = User.create!(
          email: "seller#{n}@exmaple.com",
          name: users[n]['name'],
          image: File.open(image_path),
          password: "password",
          confirmed_at: Time.now,
          is_seller: true,
          is_dammy: true,
          #categories: categories[n%3],
          description: users[n]['description'],
          last_login_at:DateTime.now
      )
      user.user_categories.create(category: Category.find(n%Category.count+1))
      user = User.create!(
          email: "buyer#{n}@exmaple.com",
          name: users[n]['name'],
          password: "password",
          confirmed_at: Time.now,
          is_seller: false,
          is_dammy: true,
          #categories: categories[n%3],
          description: users[n]['description'],
          last_login_at:DateTime.now
      )
      user.user_categories.create(category: Category.find(n%Category.count+1))
      rescue => e
        puts e
      end
    end
  end

  task create_services: :environment do
    file_path = Rails.root.join('public','sample', 'services.json')
    services = JSON.parse(File.read(file_path))
    10.times do |n|
      service = Service.create!(
        user: User.find_by(email: "seller#{n}@exmaple.com"),
        title: services[0]['title'],
        description: services[0]['description'],
        price: (n+1)*100,
        category_id: Category.find(n%Category.count+1).id,
        stock_quantity: n + 1,
        transaction_message_days: n%30,
        delivery_days: n%14 + 1,
        request_form_name: Form.find_by(name: 'text').name_sym,
        delivery_form_name: Form.find_by(name: 'text').name_sym,
        request_max_characters: (n+1)*50,
        request_max_minutes: n,
        request_max_files: 0,
        is_inclusive: true
      )
    end
  end

  task create_requests: :environment do
    file_path = Rails.root.join('public','sample', 'transactions.json')
    transactions = JSON.parse(File.read(file_path))
    #10.times do |n|
    Parallel.each(0..9) do |n|
      image_path = Rails.root.join('public','sample', "canvas (#{n}).jpg")
      if File.exist?(image_path)
        request = Request.create!(
          user:User.first,
          title: transactions[n]['question']['title'],
          description: transactions[n]['question']['description'],
          max_price: (n+2)*500,
          mini_price: (n+1)*500,
          category_id: Category.find(n%Category.count+1).id,
          image: File.open(image_path),
          use_youtube:false,
          suggestion_deadline: DateTime.now + n + 1,
          request_form_name: Form.find_by(name:"text").name.to_sym,
          delivery_form_name: Form.find_by(name:"text").name.to_sym,
          total_services: 0,
          is_published: true,
          published_at:DateTime.now - n + 2,
          total_views:0,
          is_inclusive: true
        )
      else
        # ファイルが存在しない場合の処理
        puts "ファイルが見つかりません: #{file_path}"
      end
    end
  end

  task create_transactions: :environment do
    file_path = Rails.root.join('public','sample', 'transactions.json')
    transactions = JSON.parse(File.read(file_path))
    file_path = Rails.root.join('public','sample', 'services.json')
    services = JSON.parse(File.read(file_path))
    Parallel.each(0..9) do |n|
      image_path = Rails.root.join('public','sample', "canvas (#{n}).jpg")
      buyers = User.where(is_seller: false)
      sellers = User.where(is_seller: true)
      request = Request.create!(
        user: buyers[n%buyers.count+1],
        title: transactions[n]['question']['title'],
        description: transactions[n]['question']['description'],
        max_price: (n+2)*500,
        mini_price: (n+1)*500,
        category_id: Category.find(n%Category.count+1).id,
        image: File.open(image_path),
        use_youtube:false,
        suggestion_deadline: DateTime.now + n + 1,
        request_form_name: Form.find_by(name:"text").name.to_sym,
        delivery_form_name: Form.find_by(name:"text").name.to_sym,
        total_services: 0,
        is_published: true,
        published_at:DateTime.now - n + 2,
        total_views:0,
        is_inclusive: false
      )
      puts "seller#{n}@exmaple.com"
      service = Service.create!(
        user: User.find_by(email: "seller#{n}@exmaple.com"),
        title: services[0]['title'],
        description: services[0]['description'],
        price: (n+1)*100,
        category_id: Category.find(n%Category.count+1).id,
        stock_quantity: n + 1,
        transaction_message_days: n%30,
        delivery_days: n%14 + 1,
        request_form_name: Form.find_by(name: 'text').name_sym,
        delivery_form_name: Form.find_by(name: 'text').name_sym,
        request_max_characters: (n+1)*50,
        request_max_minutes: n,
        request_max_files: 0,
        is_inclusive: true
      )
      transaction = Transaction.create!(
        title: transactions[n]['answer']['title'],
        description: transactions[n]['answer']['description'],
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
    end
  end
end
