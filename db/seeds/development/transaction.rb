categories = ["career","business","job_hunting"]
#youtube_ids = ["AL1exql33qM","bOnBJyqmqOc","qDZeB-tCLNE"]
youtube_ids = ["EqboAI-Vk-U"]
service = Service.first
60.times do |n|
    transaction = Transaction.create!(
        title:"ここに成果物のタイトルが表示される",
        description:"ここに成果物の説明が表示される。",
        service_id: service.id,
        request_id:1,
        #seller_id:1,
        #buyer_id:2,
        is_contracted:true,
        contracted_at:DateTime.now,
        is_transacted:true,
        transacted_at: DateTime.now - n,
        stripe_payment_id:"pi_3LO0pXFsZJRtLc1j0OJU7Mlg",
        #price:service.price,
        #profit:service.price*(1-transaction_margin),
        #margin:service.price*transaction_margin,
        #category_id:Category.find_by(name: categories[n%3]).id,
        use_youtube:true,
        youtube_id: youtube_ids[n % youtube_ids.length],
        transaction_message_days: service.transaction_message_days,
        star_rating: n%6,
        review_description: "レビュー内容をここに表示",
        reviewed_at: DateTime.now - n,
        is_published:false
        #star_rating:n%5,
        #review_description:"ここにレビューが表示される",
        #reviewed_at:DateTime.now - n
    )
    transaction.items.create(
        youtube_id:youtube_ids[n%youtube_ids.length],
    )
    transaction.update(is_published:true)
    #transaction.transaction_categories.create(category: Category.find_by(name: categories[n%3]))
end