class CreateInquiries < ActiveRecord::Migration[6.1]
  def change
    create_table :inquiries do |t|
      t.references :user, foreign_key: true
      t.string :name, null: false, default: ''
      t.string :email, null: false, default: ''
      t.text :body, null: false, default: ''
      t.text :answer, null: false, default: ''
      t.boolean :is_replied, default: false, null: false

      t.references :admin_user, foreign_key: true
      t.timestamps
    end
  end
end
