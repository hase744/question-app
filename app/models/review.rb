class Review
    include ActiveModel::Model
    attr_accessor :user, :description, :star_rating, :reviewed_at, :transaction_id
    
    validates :star_rating, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5}
    def transaction
        Transaction.find(self.transaction_id)
    end

    def save
        self.transaction.update(
            star_rating: self.star_rating, 
            review_description: self.description,
            reviewed_at: DateTime.now
            )
    end
end