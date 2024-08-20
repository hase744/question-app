class ServiceCategory < ApplicationRecord
  enum category_name: Category.all.map{|c| c.name.to_sym}, _prefix: true
  #belongs_to :category
  belongs_to :service
  def category
    Category.find_by(name: category_name)
  end

  #belongs_to :category, primary_key: :name, foreign_key: :category_name, class_name: 'Category'
end
