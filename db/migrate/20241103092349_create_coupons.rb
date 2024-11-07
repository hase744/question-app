class CreateCoupons < ActiveRecord::Migration[6.1]
  def change
    create_table :coupons do |t|
      t.references :user, null: false, index:true, foreign_key: true
      t.integer :amount, default: 0, null: false
      t.float :discount_rate, null: false
      t.datetime :start_at
      t.datetime :end_at
      t.integer :minimum_purchase_amount, default: 0, null: false
      t.integer :remaining_amount, default: 0, null: false
      t.integer :usage_type, null: false
      t.boolean :is_active, null: false, default: false

      t.timestamps
    end
  end
end
