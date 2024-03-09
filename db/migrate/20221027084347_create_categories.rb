class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :japanese_name
      t.text :description
      t.references :parent_category, foreign_key: { to_table: :categories }
      t.datetime :start_at
      t.datetime :end_at
  
      t.timestamps
    end
  end
end