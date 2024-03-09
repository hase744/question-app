class CreateRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table :relationships do |t|
      t.references :followee, null: false, index:true, foreign_key: { to_table: :users }
      t.references :follower, null: false, index:true, foreign_key: { to_table: :users }
      t.boolean :is_blocked, default:false, index:true

      t.timestamps
    end
  end
end