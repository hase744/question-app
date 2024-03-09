class CreateAdminUserRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_user_roles do |t|
      t.references :role, foreign_key: true
      t.references :admin_user, foreign_key: true

      t.timestamps
    end
  end
end
