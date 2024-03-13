class ApplicationRecord < ActiveRecord::Base
  require_relative "country.rb"
  require_relative "form.rb"
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  self.abstract_class = true
  include CommonMethods
  include CategoryConfig
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
  
  def image_with_default
    self.image&.url.present? ? self.image.url : '/corretech_icon.png'
  end
end
