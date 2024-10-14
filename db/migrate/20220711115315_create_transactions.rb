class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :seller, index:true, foreign_key: { to_table: :users}
      t.references :buyer, index:true, foreign_key: { to_table: :users}
      t.references :service, null: false, index:true, foreign_key: true
      t.references :request, null: false, index:true, foreign_key: true
      t.integer :request_form_name, null: false, index:true
      t.integer :delivery_form_name, null: false, index:true

      t.datetime :delivery_time
      t.datetime :service_checked_at
      #t.references :category, index:true
      t.integer :price, index:true
      t.text :service_title
      t.text :service_descriprion
      t.boolean :service_allow_pre_purchase_inquiry
      t.integer :profit, index:true
      t.integer :margin
      t.string :stripe_payment_id
      t.string :stripe_transfer_id
      t.string :title, index:true
      t.text :description
      t.datetime :pre_purchase_inquired_at
      t.integer :total_views, default: 0, index:true

      t.boolean :is_transacted, default: false, index:true #納品されているか
      t.datetime :transacted_at, index:true

      t.boolean :is_published, default: false, index:true #納品されているか
      t.datetime :published_at, index:true

      t.boolean :is_violating, default:false, index:true #規約に違反しているか
      t.boolean :violating_reason, index:true #規約に違反しているか

      t.boolean :is_reveresed, default:false, index:true #規約に違反しているか
      t.datetime :reveresed_at, index:true

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

      #レビューに関連するカラム
      t.integer :star_rating, index:true
      t.text :review_description
      t.datetime :reviewed_at
      t.text :review_reply

      t.timestamps
    end
  end
end
