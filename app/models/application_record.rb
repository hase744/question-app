class ApplicationRecord < ActiveRecord::Base
  require_relative "country.rb"
  require_relative "form.rb"
  self.abstract_class = true
  include CommonMethods
  include CategoryConfig
  include FormConfig
  include OperationConfig
  include Variables
  include CommonConcern
  include TemplateConcern

  scope :filter_categories, -> (params){
    ids = Category.all.map{|category|
      if params[category.name.to_sym] == '1'
        category.id
      end
    }.compact
    joins(:categories)
    .where(categories: { id: ids }) if ids.length > 0
  }

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
end
