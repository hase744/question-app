class CreateContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :contacts do |t|
      t.references :room, null: false, index:true, foreign_key: true
      t.references :user, null: false, index:true, foreign_key: true
      t.references :destination, null: false, index:true, foreign_key: { to_table: :users }
      t.boolean :new_message_exists, index:true, default: false
      t.boolean :is_blocked, default: false, index:true
      t.boolean :is_valid, index:true, default:false, index:true

      t.timestamps
    end
  end
end
