class CreateRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table :relationships do |t|
      t.references :user, null: false, index:true, foreign_key: { to_table: :users }
      t.references :target_user, foreign_key: { to_table: :users }
      t.integer :type_name, default: 0, null: false # enum用にintegerカラムを追加

      t.timestamps
    end
  end
end