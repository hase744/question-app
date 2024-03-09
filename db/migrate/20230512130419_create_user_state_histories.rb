class CreateUserStateHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :user_state_histories do |t|
      t.references :state, null: false, foreign_key: { to_table: :user_states }
      t.references :user, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
