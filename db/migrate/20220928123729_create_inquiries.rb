class CreateInquiries < ActiveRecord::Migration[6.1]
  def change
    create_table :inquiries do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :email
      t.text :body
      t.text :answer

      t.references :admin_user, foreign_key: true
      t.timestamps
    end
  end
end
