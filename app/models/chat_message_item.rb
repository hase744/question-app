class ChatMessageItem < ApplicationRecord
  belongs_to :message, class_name: 'ChatMessage', foreign_key: :chat_message_id, optional: true #optional: trueじゃないとbuildできない
  delegate :sender, to: :message
  mount_uploader :file, ImageUploader
  store_in_background :file
  after_save :update_item_src
  attr_accessor :save_in_background

  def thumb_with_default
    return "/updating_normal_size.jpg" if self.file_processing
    self.file&.thumb&.url.presence || "/corretech_icon.png"
  end

  def user
    self.sender
  end
end
