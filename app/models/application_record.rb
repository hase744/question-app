class ApplicationRecord < ActiveRecord::Base
  require_relative "country.rb"
  require_relative "form.rb"
  require_relative "category.rb"
  self.abstract_class = true
  include CommonMethods
  include FormConfig
  include OperationConfig
  include Variables
  include CommonConcern
  include TemplateConcern


  def self.acceptable_video_extensions
    extensions = FileUploader.new.extension_allowlist - ImageUploader.new.extension_allowlist
    extensions = extensions.map{|extension|
      "video/#{extension}"
    }.join(',')
  end
  
  def self.acceptable_image_extensions
    extensions =  ImageUploader.new.extension_allowlist
    extensions = extensions.map{|extension|
      "image/#{extension}"
    }.join(',')
  end

  def request_form_has_image?
    if ['text','image','free'].include?(request_form.name)
      true
    else
      false
    end
  end

  def delivery_form_has_image?
    if ['text','image','free'].include?(delivery_form.name)
      true
    else
      false
    end
  end

  def liked_class(user)
    if self.likes.where(user: user).present?
      "liked_button"
    else
      "not_liked_button"
    end
  end
end
