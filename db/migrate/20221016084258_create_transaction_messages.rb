class CreateTransactionMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :transaction_messages do |t|
      t.references :transaction, null: false, index:true, foreign_key: { to_table: :transactions }
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.string :file
      t.text :body
      t.integer :total_likes, default: 0, index:true
      t.string :file

      t.timestamps
    end
  end
end
