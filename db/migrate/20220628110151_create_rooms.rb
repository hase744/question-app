class CreateRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :rooms do |t|
      t.text :last_message
      t.datetime :last_message_at
      t.boolean :is_blocked, index:true

      t.timestamps
    end
  end
end