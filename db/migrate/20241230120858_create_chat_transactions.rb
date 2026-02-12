class CreateChatTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_transactions do |t|
      t.references :buyer, null: false, index:true, foreign_key: { to_table: :users}
      t.references :chat_service, null: false, index:true, foreign_key: true
      t.references :chat_destination, null: false, index:true, foreign_key: true

      t.integer :state, index:true
      t.integer :type_name, index:true
      t.integer :count, index:true
      t.integer :remaining_count, index:true
      t.integer :limit, index:true

      t.integer :price, index:true
      t.integer :profit, index:true
      t.integer :fee, index:true

      t.datetime :transacted_at, index:true
      t.datetime :sended_at, index:true
      t.datetime :canceled_at, index:true

      t.timestamps
    end
  end
end
