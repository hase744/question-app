class CreateChatDestinations < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_destinations do |t|
      t.references :chat_room, null: false, index:true, foreign_key: true
      t.references :user, null: false, index:true, foreign_key: true
      t.references :target, null: false, index:true, foreign_key: { to_table: :users }
      t.boolean :is_unread, index:true, default: false

      t.timestamps
    end
  end
end