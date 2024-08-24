module CategoryBase
  class Base < ActiveRecord::Base
    self.abstract_class = true
    after_save :update_user_category
    enum category_name: Category.all.map { |c| c.name.to_sym }, _prefix: true
    
    def category
      Category.find_by(name: category_name)
    end

    def update_user_category
      puts "アップデート"
      self.user.update_categories
    end
  end
end
