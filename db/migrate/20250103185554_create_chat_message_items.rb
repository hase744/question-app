class CreateChatMessageItems < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_message_items do |t|
      t.references :chat_message, null: false, foreign_key: true, index:true
      t.string :file
      t.string :file_tmp
      t.boolean :file_processing, null: false, default: false
      t.boolean :is_text_image, null: false, default: false
      t.string :youtube_id
      t.text :description

      t.timestamps
    end
  end
end
