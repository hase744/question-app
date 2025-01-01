class CreateChatMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_messages do |t|
      t.references :chat_room, index:true, foreign_key: true
      t.references :chat_destination, index:true, foreign_key: true
      t.references :sender, index:true, foreign_key: { to_table: :users }
      t.references :receiver, index:true, foreign_key: { to_table: :users }
      t.text :body, index:true
      t.string :file
      t.boolean :is_read, default: false

      t.timestamps
    end
  end
end
