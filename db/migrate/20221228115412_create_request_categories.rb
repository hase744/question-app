class CreateRequestCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :request_categories do |t|
      t.integer :category_name, null: false, index:true
      t.references :request, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
