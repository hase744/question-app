class FileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include ::CarrierWave::Backgrounder::Delay
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog
  # storage :fog
  cache_storage CarrierWave::Storage::File

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb, if: :is_image? do
    process resize_to_fit: [300, 300]
    process convert: 'jpg'

    def full_filename(for_file)
      super(for_file).chomp(File.extname(for_file)) + '.jpg'
    end
  end

  version :normal_size, if: :is_image? do
    process resize_to_fit: [1000, 1000]
    process convert: 'jpg'

    def full_filename(for_file)
      super(for_file).chomp(File.extname(for_file)) + '.jpg'
    end
  end
  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def image_extensions
    %w(jpg jpeg gif png)
  end

  def video_extensions
    %w(MOV mov wmv mp4)
  end
  
  def is_image?(new_file = nil) #上のversion :thumb, if: :is_image? doのための引数
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

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
