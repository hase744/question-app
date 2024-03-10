class CreateUserStateHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :user_state_histories do |t|
      t.integer :state
      t.references :user, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
