class CreateServiceLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :service_likes do |t|
      t.references :service, null: false, index:true, foreign_key: true
      t.references :user, null: false, index:true, foreign_key: true

      t.timestamps
    end
  end
end
