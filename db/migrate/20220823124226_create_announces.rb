class CreateAnnounces < ActiveRecord::Migration[6.1]
  def change
    create_table :announces do |t|
      t.string :title
      t.text :body
      t.datetime :disclosed_at
      t.string :file

      t.timestamps
    end
  end
end
