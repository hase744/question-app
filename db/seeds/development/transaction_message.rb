30.times do |n|
    if n%2 == 1
        sender_id = 1
        receiver_id = 2
    else
        sender_id = 2
        receiver_id = 1
    end
    TransactionMessage.create(transaction_id:1, sender_id:sender_id, receiver_id:receiver_id, body:"#{n}番目のメッセージここにやり取りしたいメッセージを表示させる")
end