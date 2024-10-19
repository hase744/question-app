class CreatePayouts < ActiveRecord::Migration[6.1]
  def change
    create_table :payouts do |t|
      t.references :user, null: false, foreign_key: true, index:true
      t.integer :amount, null: false, default: 0, index:true
      t.integer :fee, null: false, default: 0, index:true
      t.integer :total_deduction, null: false, default: 0, index:true
      t.integer :status_name, null: false
      t.string :stripe_payout_id
      t.string :stripe_account_id
      t.datetime :executed_at, null: false

      t.timestamps
    end
  end
end
