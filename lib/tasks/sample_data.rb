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
        user = User.new(
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
        user.process_image_upload = true
        user.process_header_image_upload = true
        user.assign_attributes(
          image: File.open(image_path),
          header_image: File.open(header_image_path),
          )
        user.save
        puts "creating seller No.#{n}"
        user.user_categories.create(category_name: category.name)

        user = User.find_by(email: "buyer#{category.name}#{n}@exmaple.com")
        user = User.new(
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
        user.save
        puts "creating buyer No.#{n}"
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
        puts "creating service No.#{n}"
        service_image_path = Rails.root.join('public', 'sample', category.name, "service_image(#{n}).jpg")
        service = Service.create_or_find_by!(
          user: User.find_by(email: "seller#{category.name}#{n}@exmaple.com"),
          title: services[n]['title'],
          description: services[n]['description'],
          price: (4 * n + 2) * 100,
          category_id: category.id,
          transaction_message_enabled: true,
          delivery_days: n%14 + 1,
          request_form_name: Form.find_by(name: 'text').name_sym,
          delivery_form_name: Form.find_by(name: 'text').name_sym,
          request_max_characters: (n+1)*200,
          request_max_minutes: n,
          service_categories_attributes: {"0"=>{"category_name"=>category.name}}
        )
        item = service.items.new()
        item.process_file_upload = true
        item.assign_attributes(file: File.open(service_image_path))
        if item.save
          puts "succeeded : service No.#{n}"
        else
          puts "failed : service No.#{n}"
          puts "reason : #{service.errors.full_messages}"
        end
        #service.service_categories.create(category_name: category.name)
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
          puts "creating request No.#{n}"
          request = Request.create_or_find_by!(
            user: User.find_by(email: "buyer#{category.name}#{n}@exmaple.com"),
            title: transactions[n]['question']['title'],
            description: transactions[n]['question']['description'],
            max_price: (n+2)*500,
            mini_price: (n+1)*500,
            suggestion_deadline: DateTime.now + n + 1,
            request_form_name: Form.find_by(name:"text").name.to_sym,
            delivery_form_name: Form.find_by(name:"text").name.to_sym,
            total_services: 0,
            is_published: false,
            published_at:DateTime.now - n + 2,
            total_views:0,
            is_inclusive: true,
            is_accepting: true,
            request_categories_attributes: {"0"=>{"category_name"=>category.name}}
          )
          #request.request_categories.create(category_name: category.name)
          request.set_publish
          item = request.build_item
          item.process_file_upload = true
          item.assign_attributes(file: File.open(image_path), is_text_image:true)
          if request.save && item.save
            puts "succeeded : request No.#{n}"
          else
            puts "failed : request No.#{n}"
            puts "reason : #{request.errors.full_messages}"
          end
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
        service_image_path = Rails.root.join('public', 'sample', category.name, "service_image(#{n}).jpg")
        buyer = User.find_by(email: "buyer#{category.name}#{n}@exmaple.com")
        seller = User.find_by(email: "seller#{category.name}#{n}@exmaple.com")
        request = Request.create_or_find_by!(
          user: buyer,
          title: transactions[n]['question']['title'],
          description: transactions[n]['question']['description'],
          max_price: (n+2)*500,
          mini_price: (n+1)*500,
          suggestion_deadline: DateTime.now + n + 1,
          request_form_name: Form.find_by(name:"text").name.to_sym,
          delivery_form_name: Form.find_by(name:"text").name.to_sym,
          total_services: 0,
          is_published: false,
          published_at:DateTime.now - n + 2,
          total_views:0,
          is_inclusive: false,
          is_accepting: true,
          request_categories_attributes: {"0"=>{"category_name"=>category.name}}
        )
        #request.request_categories.create(category_name: category.name)
        request.set_publish
        item = request.build_item
        item.process_file_upload = true
        item.assign_attributes(file: File.open(image_path), is_text_image:true)
        if request.save && item.save
          puts "succeeded : request No.#{n}"
        else
          puts "failed : request No.#{n}"
          puts "reason : #{request.errors.full_messages}"
        end
        puts "seller#{n}@exmaple.com"
        service = Service.create_or_find_by!(
          user: seller,
          title: services[n]['title'],
          description: services[n]['description'],
          price: (4 * n + 2) * 100,
          transaction_message_enabled: true,
          delivery_days: n%14 + 1,
          request_form_name: Form.find_by(name: 'text').name_sym,
          delivery_form_name: Form.find_by(name: 'text').name_sym,
          request_max_characters: (n+1)*500,
          request_max_minutes: n,
          service_categories_attributes: {"0"=>{"category_name"=>category.name}}
        )
        item = service.items.new()
        item.process_file_upload = true
        item.assign_attributes(file: File.open(service_image_path))
        item.save
        #service.service_categories.create(category_name: category.name)
        transaction = Transaction.create_or_find_by!(
          title: transactions[n]['answer']['title'],
          description: transactions[n]['answer']['description'],
          buyer: buyer,
          service: service,
          request: request,
          is_contracted:true,
          contracted_at:DateTime.now,
          is_transacted:true,
          is_published:true,
          transacted_at: DateTime.now - n,
          published_at: DateTime.now - n,
          stripe_payment_id:"pi_3LO0pXFsZJRtLc1j0OJU7Mlg",
          transaction_message_enabled: service.transaction_message_enabled,
        )
        transaction.create_review(
          star_rating: 4 + (n % 2),
          body: "レビュー内容をここに表示",
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