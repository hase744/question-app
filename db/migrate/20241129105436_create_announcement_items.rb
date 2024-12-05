class CreateAnnouncementItems < ActiveRecord::Migration[6.1]
  def change
    create_table :announcement_items do |t|
      t.references :announcement, null: false, index:true, foreign_key: true
      t.string :file
      t.string :file_tmp
      t.boolean :file_processing, null: false, default: false
      t.text :description

      t.timestamps
    end
  end
end
