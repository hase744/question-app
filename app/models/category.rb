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
end
