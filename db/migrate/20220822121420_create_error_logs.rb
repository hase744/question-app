class CreateErrorLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :error_logs do |t|
      t.references :user, index:true, foreign_key: true, null: true
      t.string :uuid, null: false, index:true
      t.string :error_class
      t.text :error_message
      t.text :error_backtrace
      t.string :method
      t.string :controller
      t.string :action
      t.integer :id_number
      t.text :parameter

      t.timestamps
    end
  end
end
