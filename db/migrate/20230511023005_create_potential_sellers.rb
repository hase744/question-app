class CreatePotentialSellers < ActiveRecord::Migration[6.1]
  def change
    create_table :potential_sellers do |t|
      t.string :name
      t.string :email
      t.string :url
      t.references :media, foreign_key: true
      t.references :user, foreign_key: true
      t.references :inviter, foreign_key: { to_table: :admin_users }
      t.references :proposer, foreign_key: { to_table: :admin_users }
      t.references :category, foreign_key: true
      t.integer :total_followers
      t.text :description
      t.text :profile_description
      t.boolean :is_allowed
      t.boolean :is_checked
      t.string :reward #事前出品の報酬の内容
      t.boolean :is_rewarded #事前登録の報酬を贈ったか
      t.text :allowance_reason

      t.timestamps
    end
  end
end
