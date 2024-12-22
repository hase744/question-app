class CreateRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :requests do |t|
      t.references :user, null: false, index:true, foreign_key: true
      t.integer :request_form_name, null: false, index:true
      t.integer :delivery_form_name, null: false, index:true
      t.string :title, index:true
      t.text :description

      t.integer :reward, index:true
      t.integer :max_price, index:true
      t.integer :mini_price, index:true #予算の下限　※現在は未使用

      t.boolean :is_inclusive, index:true, null: false, default: true
      t.boolean :is_accepting, index: true, null: false, default: true
      t.datetime :retracted_at, index:true
      t.integer :suggestion_acceptable_duration, index:true
      t.datetime :suggestion_deadline, index:true

      t.integer :description_total_characters, default: 0, index:true
      t.integer :file_duration, default: nil, index:true
      t.integer :total_files, default: 0, index:true
      t.integer :total_views, default: 0, index:true
      t.integer :total_services, default: 0, index:true

      t.boolean :is_disabled, default:false, index:true
      t.datetime :disabled_at
      t.text :disable_reason

      t.references :transaction, index:true
      t.boolean :is_published, default: false, index:true
      t.datetime :published_at, index:true

      t.integer :mode, null: false

      t.timestamps
    end
  end
end