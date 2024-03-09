class AddReferecncesToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :country, foreign_key: true
  end
end
