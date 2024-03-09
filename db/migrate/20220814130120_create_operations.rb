class CreateOperations < ActiveRecord::Migration[6.1]
  def change
    create_table :operations do |t|
      t.references :state, foreign_key: true
      t.datetime :start_at, null: false
      t.text :comment
      t.references :admin_user, foreign_key: true

      t.timestamps
    end
  end
end
