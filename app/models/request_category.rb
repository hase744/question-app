class RequestCategory < ApplicationRecord
  #belongs_to :category
  enum category_name: Category.all.map{|c| c.name.to_sym}, _prefix: true
  belongs_to :request
end
