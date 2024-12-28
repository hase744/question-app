class CreateAnnouncements < ActiveRecord::Migration[6.1]
  def change
    create_table :announcements do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.text :description, null: false
      t.references :admin_user
      t.integer :condition_type, null: false
      t.text :target_condition
      t.datetime :published_at, null: false
      t.boolean :is_read, null: false, default: false

      t.timestamps
    end
  end
end
