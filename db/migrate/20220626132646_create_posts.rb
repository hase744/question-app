class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, index:true, foreign_key: true
      t.text :body
      t.string :file
      t.string :file_tmp
      t.boolean :file_processing, null: false, default: false
      t.integer :total_views, default: 0, index:true

      t.timestamps
    end
  end
end
