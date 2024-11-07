class CreateCouponUsages < ActiveRecord::Migration[6.1]
  def change
    create_table :coupon_usages do |t|
      t.references :coupon, null: false, index:true, foreign_key: true
      t.references :transaction, null: false, index:true, foreign_key: true
      t.integer :amount, default: 0, null: false

      t.timestamps
    end
  end
end
