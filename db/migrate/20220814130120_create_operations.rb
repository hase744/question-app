class CreateOperations < ActiveRecord::Migration[6.1]
  def change
    create_table :operations do |t|
      t.integer :state
      t.datetime :start_at, null: false
      t.text :comment
      t.references :admin_user, foreign_key: true

      t.timestamps
    end
  end
end
