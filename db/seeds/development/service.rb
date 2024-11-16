#categories = ["Apex", "Valorant", "Splatoon"]
categories = ["career","business","job_hunting"]
request_forms = ["video","image","text","text","video","image"]
duration_arrays = [10,nil,nil,nil,5,nil]
delivery_forms = ["video","image","text"]

file = File.open("./public/front_image.jpeg")
file = CarrierWave::SanitizedFile.new(tempfile: file)


40.times do |n|
    user = User.where(is_seller:true)[n % User.where(is_seller:true).count]
    service = Service.create!(
        user:user,
        title:"ここにタイトルが表示される。",
        description: "ここにサービス内容の説明を表示させる。",
        price: (n+1)*100,
        category_id: Category.find(n%Category.count+1).id,
        delivery_days: n%14 + 1,
        request_form_name: Form.find_by(name: 'text').name_sym,
        delivery_form_name: Form.find_by(name: 'text').name_sym,
        request_max_characters: (n+1)*50,
        request_max_minutes: duration_arrays[n%6],
        request_max_files:0,
    )
    #service.service_categories.create(category: Category.find_by(name: categories[n%3]))
    #user.update(mini_price: Service.where(user: user, request_id:nil, is_published:true).minimum(:price))
end
