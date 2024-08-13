class CreateServiceItems < ActiveRecord::Migration[6.1]
  def change
    create_table :service_items do |t|
      t.references :service, null: false, foreign_key: true, index:true
      t.string :file
      t.string :youtube_id
      t.text :description

      t.timestamps
    end
  end
end
