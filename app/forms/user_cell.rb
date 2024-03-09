class UserCell
    include ActiveModel::Model
    attr_accessor :id, :name, :image, :categories, :average_star_rating, :total_reviews, :sale_count, :product_number, :cumulated_like, :last_login_at, :min_price, :description
    
end