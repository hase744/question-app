class CreateServices < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.references :user, null: false, index:true, foreign_key: true
      t.integer :request_form_name, index:true
      t.integer :delivery_form_name, index:true
      t.references :request, index:true, foreign_key: true
      t.string :title, index:true
      t.text :description
      t.integer :price
      t.boolean :is_published, default: true, index:true
      t.boolean :is_for_sale, default: true, index:true
      t.integer :delivery_days, index:true

      t.integer :request_max_characters, index:true, default: nil
      t.integer :request_max_duration, index:true
      t.datetime :renewed_at #サービス内容が更新された日時

      t.boolean :transaction_message_enabled, nil: false, default: true
      t.boolean :allow_pre_purchase_inquiry, nil: false, default: true

      t.integer :total_views, default: 0, index:true
      t.integer :total_reviews, default: 0, index:true
      t.float :average_star_rating, default: nil, index:true

      t.boolean :is_disabled, default:false, index:true
      t.datetime :disabled_at
      t.text :disable_reason

      t.float :rejection_rate, default: nil, index:true
      t.float :cancellation_rate, default: nil, index:true
    
      t.integer :mode, null: false

      t.timestamps
    end
  end
end
