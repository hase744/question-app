class CreateRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :requests do |t|
      t.references :user, null: false, index:true, foreign_key: true
      #t.references :service, index:true
      t.integer :request_form_name, null: false, index:true
      t.integer :delivery_form_name, null: false, index:true
      #t.references :category, index:true
      t.string :title, index:true
      t.text :description
      t.string :image

      t.integer :max_price, index:true
      t.integer :mini_price, index:true #予算の加減　＊現在は未使用

      #t.string :file
      #t.string :thumbnail #サムネイル
      #t.string :youtube_id
      #t.boolean :use_youtube, default: false

      t.boolean :is_inclusive, index:true
      t.integer :suggestion_acceptance_duration, index:true
      t.datetime :suggestion_deadline, index:true

      t.integer :description_total_characters, default: 0, index:true
      t.integer :file_duration, default: nil, index:true
      t.integer :total_files, default: 0, index:true
      t.integer :total_views, default: 0, index:true
      t.integer :total_services, default: 0, index:true
      t.integer :total_likes, default: 0, index:true
      t.integer :transaction_message_days, index:true

      t.references :transaction, index:true
      #t.integer :total_contracts, default: 0
      t.boolean :is_published, default: false, index:true
      t.datetime :published_at, index:true

      t.timestamps
    end
  end
end