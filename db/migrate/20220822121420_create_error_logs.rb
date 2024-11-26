class CreateErrorLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :error_logs do |t|
      t.references :user, index:true, foreign_key: true, null: true
      t.string :error_class
      t.text :error_message
      t.text :error_backtrace
      t.string :request_method
      t.string :request_controller
      t.string :request_action
      t.integer :request_id_number
      t.text :request_parameter

      t.timestamps
    end
  end
end
