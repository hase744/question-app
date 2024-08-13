class AddImageTmpToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :image_tmp, :string
  end
end
