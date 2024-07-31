class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :seller, index:true, foreign_key: { to_table: :users}
      t.references :buyer, index:true, foreign_key: { to_table: :users}
      t.references :service, null: false, index:true, foreign_key: true
      t.references :request, null: false, index:true, foreign_key: true

      t.datetime :delivery_time
      #t.references :category, index:true
      t.integer :price, index:true
      t.text :service_title
      t.text :service_descriprion
      t.integer :profit, index:true
      t.integer :margin
      t.string :stripe_payment_id
      t.string :stripe_transfer_id
      t.string :title, index:true
      t.text :description
      t.integer :total_views, default: 0, index:true
      t.integer :total_likes, default: 0, index:true

      t.boolean :is_delivered, default: false, index:true #納品されているか
      t.datetime :delivered_at, index:true

      t.boolean :is_violating, default:false, index:true #規約に違反しているか

      t.boolean :is_contracted, default:false, index:true #売買が成立しているか
      t.datetime :contracted_at, index:true

      t.boolean :is_suggestion, default:false, index:true #提案状態であるか
      t.datetime :suggested_at, index:true

      t.boolean :is_rejected, default:false, index:true #拒否されているか
      t.datetime :rejected_at, index:true
      t.text :reject_reason


      t.boolean :is_canceled, default: false #キャンセルされているか
      t.datetime :canceled_at, index:true
      
      #t.integer :transaction_message_days, default:0
      t.boolean :transaction_message_enabled, default: false
      #t.datetime :transaction_message_deadline
      t.boolean :is_published, default:false

      #レビューに関連するカラム
      t.integer :star_rating, index:true
      t.text :review_description
      t.datetime :reviewed_at
      t.text :review_reply

      t.timestamps
    end
  end
end
