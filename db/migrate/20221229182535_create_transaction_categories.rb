class CreateTransactionCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :transaction_categories do |t|
      t.integer :category_name, null: false, index:true
      t.references :transaction, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
