class TransactionCategory < ApplicationRecord
  #belongs_to :category
  enum category_name: Category.all.map{|c| c.name.to_sym}, _prefix: true
  belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id, dependent: :destroy
end
