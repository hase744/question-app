class CreateReviews < ActiveRecord::Migration[6.1]
  def change
    create_table :reviews do |t|
      t.references :transaction, null: false, index:true, foreign_key: true
      t.integer :star_rating, index:true
      t.text :body
      t.text :reply

      t.timestamps
    end
  end
end