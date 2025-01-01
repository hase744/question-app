class CreateChatServices < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_services do |t|
      t.references :user, null: false, index:true, foreign_key: true
      t.integer :price, null: false, index:true
      t.integer :type, index:true

      t.timestamps
    end
  end
end
