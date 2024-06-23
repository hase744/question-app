class Category < ApplicationRecord
    belongs_to :parent_category, class_name: "Category", optional: true
    has_many :user_categories
    has_many :service_categories
    has_one :service_category
    has_one :service, through: :service_category
    has_many :request_categories
    has_many :requests, through: :request_categories
    has_many :transaction_categories
    has_many :deals, through: :transaction_categories
    has_many :child_categories, class_name: "Category", foreign_key: :parent_category_id, dependent: :destroy
    after_commit :update_category_config

    def as_json_tree
        {
          id: id,
          name: name,
          japanese_name: japanese_name,
          child_categories: child_categories.map(&:as_json_tree)
        }
      end
    
      # Class method to get the tree structure
      def self.to_json_tree
        roots = where(parent_category_id: nil)
        {
          tree: roots.map(&:as_json_tree)
        }
      end
end
