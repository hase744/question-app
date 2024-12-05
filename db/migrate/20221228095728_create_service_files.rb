class CreateServiceFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :service_files do |t|
      t.references :service, null: false, foreign_key: true
      t.string :file

      t.timestamps
    end
  end
end
