class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, index:true, foreign_key: true
      t.references :notifier, foreign_key: { to_table: :users }
      t.text :title
      t.text :description
      t.string :image
      t.boolean :is_notified, index:true, default:false
      t.string :controller, index:true
      t.string :action, index:true
      t.integer :id_number, index:true
      t.string :parameter
      t.datetime :published_at

      t.timestamps
    end
  end
end
