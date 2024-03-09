@room = Room.new()
@room.save


20.times do |n|
    Room.create(last_message:"部屋番号#{n+1}のメッセージ")
end
20.times do |n|
    Contact.create(user_id:1, destination_id:n+2, room_id:n+1)
    Contact.create(user_id:n+2, destination_id:1, room_id:n+1)
end

20.times do |n|
    Message.create(room_id:1, sender_id:1, receiver_id:2, contact_id: 1, body:"#{n*2}番目のメッセージ")
    Message.create(room_id:1, sender_id:2, receiver_id:1, contact_id: 2, body:"#{n*2+1}番目のメッセージ")
end