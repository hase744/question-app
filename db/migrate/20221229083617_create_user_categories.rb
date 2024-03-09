class CreateUserCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :user_categories do |t|
      t.references :category, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
