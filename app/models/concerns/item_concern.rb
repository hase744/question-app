module ItemConcern
  extend ActiveSupport::Concern
  def delete_temp_file
    # Requestなどの親モデルの保存に成功してもrequest_categoryなどの子モデルの保存に失敗すると
    # 保存が失敗した場合のみファイルを削除
    relative_path = self.file&.url.presence || self.file_tmp&.url
    return unless relative_path
    splited_path = relative_path.split('/')
    path_length = splited_path.length
    root_temp_path = Rails.root.to_s + "/tmp/" + splited_path[-2]
    public_temp_path = Rails.root.to_s + "/public/uploads/tmp/" + splited_path[-2]
    delete_folder(root_temp_path)
    delete_folder(public_temp_path)
  end

  def resave
    original_tmp_path = Rails.root.to_s + "/public/uploads/tmp/" + self.file_tmp
    original_tmp_path_array = original_tmp_path.split('/')
    original_tmp_path_array.pop
    original_tmp_foloder_path = original_tmp_path_array.join('/')
    file = File.open(original_tmp_path)
    if File.exist?(original_tmp_path) && File.exist?(original_tmp_foloder_path)
      self.process_file_upload = true
      self.file = file
      self.file_tmp = nil
      self.file_processing = true
      self.save
      delete_folder(original_tmp_foloder_path)
    end
  end

  def update_file_src(user: nil, img_mapping: [])
    FileChannel.broadcast_to(user, {
      img_mapping: img_mapping
    })
  end

  def all_items_processed?
    self.items
      .where(file_processing: true)
      .or(self.items.where(file: nil))
      .empty?
  end
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