class CreateStates < ActiveRecord::Migration[6.1]
  def change
    create_table :states do |t|
      t.string :name
      t.string :japanese_name
      t.string :description

      t.timestamps
    end
  end
end
