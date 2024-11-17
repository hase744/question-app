module ItemConcern
  extend ActiveSupport::Concern
  def normal_file_with_default
    return "/updating_normal_size.jpg" if self.file_processing
    self.file&.normal_size&.url
  end

  def thumb_file_with_default
    return "/updating_normal_size.jpg" if self.file_processing
    self.file&.thumb&.url
  end

  def normal_style_class
    "normal-img-#{self.id}"
  end

  def image_thumb_style_class
    "thumb-img-#{self.id}"
  end

  def update_item_src
    puts "アップデート"
    return unless saved_change_to_attribute?(:file_processing) && !self.file_processing
    update_file_src(
      user: self.user,
      img_mapping: [
        {
          style_class: normal_style_class,
          img_url: self.normal_file_with_default
        },
        {
          style_class: image_thumb_style_class,
          img_url: self.thumb_file_with_default
        }
      ]
    )
  end

  def file_is_image?
    if self.file_processing
      extension = self.file_tmp.split('.').last
      FileUploader.new.image_extensions.include?(extension)
    else
      return true if self.file.is_image?
    end
  end
end