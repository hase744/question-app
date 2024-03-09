20.times do |n|
    Post.create(user:User.first, body:"ここに#{n}番目に投稿した内容を表示させる。")
end