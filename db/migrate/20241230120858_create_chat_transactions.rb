class CreateChatTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_transactions do |t|
      t.references :user, null: false, index:true, foreign_key: true
      t.references :service, null: false, index:true, foreign_key: true
      t.references :chat_message, null: false, index:true, foreign_key: true

      t.integer :state, index:true
      t.integer :type, index:true

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
