class CreateServices < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.references :user, null: false, index:true, foreign_key: true
      t.integer :request_form_name, index:true
      t.integer :delivery_form_name, index:true
      #t.references :category, index:true
      #t.references :request, index:true
      t.references :request, index:true, foreign_key: true
      t.string :title, index:true
      t.text :description
      t.integer :price
      #t.integer :stock_quantity, default: 0
      t.boolean :is_published, default: true, index:true
      t.boolean :is_for_sale, default: true, index:true
      t.integer :delivery_days, index:true

      t.integer :request_max_characters, index:true, default: nil
      t.integer :request_max_duration, index:true
      t.integer :request_max_files, index:true
      t.datetime :renewed_at #サービス内容が更新された
      #t.integer :request_max_length, index:true #依頼できる最大の長さ（動画の長さ、文字数など）
      #t.integer :request_mini_length, index:true #依頼すべき最小の長さ（動画の長さ、文字数など）

      #t.integer :transaction_message_days, default: 0, index:true #追加でメッセージを送る質問できる依頼に関するカラム
      t.boolean :transaction_message_enabled, nil: false, default: true
      t.boolean :allow_pre_purchase_inquiry, nil: false, default: true

      t.integer :total_views, default: 0, index:true
      t.integer :total_sales_numbers, default: 0, index:true #過去のサービスの売上数
      t.integer :total_sales_amount, default: 0, index:true #過去のサービスの売上額
      t.integer :total_reviews, default: 0, index:true
      
      t.float :average_star_rating, default: nil, index:true
      t.float :rejection_rate, default: nil, index:true
      t.float :cancellation_rate, default: nil, index:true
      t.timestamps
    end
  end
end
