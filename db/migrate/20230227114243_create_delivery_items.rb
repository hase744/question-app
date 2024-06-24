class CreateDeliveryItems < ActiveRecord::Migration[6.1]
  def change
    create_table :delivery_items do |t|
      t.references :transaction, null: false, foreign_key: true
      t.string :file
      t.string :youtube_id
      t.text :description

      t.timestamps
    end
  end
end
