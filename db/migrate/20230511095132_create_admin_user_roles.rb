class CreateAdminUserRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_user_roles do |t|
      t.integer :role_name, foreign_key: true
      t.references :admin_user, foreign_key: true

      t.timestamps
    end
  end
end
