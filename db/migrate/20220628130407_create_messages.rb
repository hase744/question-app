class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.references :room, index:true
      t.references :contact, index:true
      t.references :sender, index:true, foreign_key: { to_table: :users }
      t.references :receiver, index:true, foreign_key: { to_table: :users }
      t.text :body
      t.string :file
      t.boolean :is_read, default: false

      t.timestamps
    end
  end
end