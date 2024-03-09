require "./app/helpers/image_helper.rb"

#categories = ["Apex", "Valorant", "Splatoon"]
categories = ["career","business","job_hunting"]
request_forms = ["video","image","text","text","video","image"]
delivery_forms = ["video","image","text"]
#youtube_ids = ["H0WznSET6MM","3c6585k-3LE","-BdsyC6xhCk"]
youtube_ids = ["_POLISGTs60","ySo7SGSwQ9s","AfGVVGJ83gg"]
n=0
#file = File.open("./public/answer.png")
file = ImageHelper.image("ここにサービス内容の説明を表示させる。")
file = CarrierWave::SanitizedFile.new(tempfile: file)

request = Request.create!(
        user:User.first,
        title:"ここにタイトルが表示される。",
        description: "ここにサービス内容の説明を表示させる。",
        max_price: (n+2)*500,
        mini_price: (n+1)*500,
        category_id: Category.find(n%Category.count+1).id,
        #file:file,
        use_youtube:false,
        youtube_id: youtube_ids[n % youtube_ids.length],
        suggestion_deadline: DateTime.now + n + 1,
        request_form: Form.find_by(name:"text"),
        delivery_form: Form.find_by(name:"text"),
        total_services: 0,
        is_published: false,
        published_at:DateTime.now - n + 2,
        total_views:0,
        is_inclusive: false
    )
    #request.items.create(
    #    youtube_id: youtube_ids[n % youtube_ids.length],
    #    file:file,
    #    thumbnail:file
    #)
    #request.update(is_published:true)
#request.request_categories.create(category:  Category.find_by(name: categories[n%3]))

20.times do |n|
    use_youtube = true
    description = "ここにサービス内容の説明を表示させる。"

    file_path = Rails.root.join('public', 'answer.png')
    file = File.open(file_path, 'rb')
    file = CarrierWave::SanitizedFile.new(tempfile: file)
    use_youtube = false
    request = Request.create!(
        user:User.where(is_seller:false)[n % User.where(is_seller:false).count - 1],
        title:"ここにタイトルが表示される。",
        description: description,
        max_price: (n+2)*100,
        mini_price: (n+1)*100,
        category_id: Category.find(n%Category.count+1).id,
        use_youtube: use_youtube,
        youtube_id: youtube_ids[n%3],
        suggestion_deadline: DateTime.now + n + 1,
        request_form: Form.find_by(name:"text"),
        delivery_form: Form.find_by(name:"text"),
        #file:file,
        is_published: false,
        published_at:DateTime.now - n + 2,
        total_views:0,
        is_inclusive: false,
    )
    request.items.create(
        #youtube_id: youtube_ids[n%3],
        file:file,
        thumbnail:file
    )
    request.update(is_published:true)
    #request.request_categories.create(category:  Category.find_by(name: categories[n%3]))
    puts n
end