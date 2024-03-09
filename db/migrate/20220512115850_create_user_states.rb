class CreateUserStates < ActiveRecord::Migration[6.1]
  def change
    create_table :user_states do |t|
      t.string :name
      t.string :japanese_name
      t.string :description

      t.timestamps
    end
  end
end
