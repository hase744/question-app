class CreateBalanceRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :balance_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :payout, foreign_key: true
      t.references :transaction, foreign_key: true
      t.integer :amount, null: false 
      t.integer :type_name, null: false
      t.text :description

      t.timestamps
    end
  end
end
