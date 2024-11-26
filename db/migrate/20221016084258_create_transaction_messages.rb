class CreateTransactionMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :transaction_messages do |t|
      t.references :transaction, null: false, index:true, foreign_key: { to_table: :transactions }
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.string :file
      t.string :file_tmp
      t.boolean :file_processing, null: false, default: false
      t.text :body
      t.datetime :published_at

      t.timestamps
    end
  end
end
