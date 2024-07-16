class CreateRequestLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :request_likes do |t|
      t.references :request, null: false, index:true, foreign_key: true
      t.references :user, null: false, index:true, foreign_key: true

      t.timestamps
    end
  end
end
