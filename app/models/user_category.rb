class UserCategory < ApplicationRecord
  #belongs_to :category
  enum category_name: Category.all.map{|c| c.name.to_sym}, _prefix: true
  belongs_to :user
  #belongs_to :category, primary_key: :name, foreign_key: :category_name, class_name: 'Category'
end
