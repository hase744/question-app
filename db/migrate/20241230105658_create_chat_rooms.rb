class CreateChatRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_rooms do |t|
      t.datetime :last_message_at, index:true
      t.text :last_message_body

      t.timestamps
    end
  end
end
