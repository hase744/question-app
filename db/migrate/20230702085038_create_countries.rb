class CreateCountries < ActiveRecord::Migration[6.1]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :japanese_name
      t.string :code

      t.timestamps
    end
  end
end
