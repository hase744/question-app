class CreateChatTransactionMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_transaction_messages do |t|
      t.references :chat_message, null: false, index:true, foreign_key: true
      t.references :chat_transaction, null: false, index:true, foreign_key: true

      t.timestamps
    end
  end
end
