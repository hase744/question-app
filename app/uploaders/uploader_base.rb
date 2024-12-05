class UploaderBase < CarrierWave::Uploader::Base
  def image_extensions
    %w(jpg jpeg gif png)
  end

  def video_extensions
    %w(MOV mov wmv mp4)
  end

  def is_image?(new_file = nil)
    new_file ||= file
    image_extensions.include?(new_file&.extension&.downcase)
  end

  def is_video?(new_file = nil)
    new_file ||= file
    video_extensions.include?(new_file&.extension&.downcase)
  end

  def extension_allowlist
    image_extensions + video_extensions
  end
end
