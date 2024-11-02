class CreateAnnouncementReceipts < ActiveRecord::Migration[6.1]
  def change
    create_table :announcement_receipts do |t|
      t.references :user, null:false
      t.references :announcement, null:false

      t.timestamps
    end
  end
end
