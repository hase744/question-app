class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_payment_id
      t.string :stripe_card_id
      t.string :stripe_customer_id
      t.boolean :is_succeeded, default:false
      t.boolean :is_refunded, default:false
      t.string :status
      t.integer :price
      t.integer :point

      t.timestamps
    end
  end
end
