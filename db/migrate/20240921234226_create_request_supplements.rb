class CreateRequestSupplements < ActiveRecord::Migration[6.1]
  def change
    create_table :request_supplements do |t|
      t.references :request, null: false, index:true, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
