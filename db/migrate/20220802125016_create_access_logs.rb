class CreateAccessLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :access_logs do |t|
      t.references :user, null: false, index:true, foreign_key: true
      t.string :ip_adress
      t.string :method
      t.string :controller
      t.string :action
      t.integer :id_number
      t.text :parameter
      t.timestamps
    end
  end
end
