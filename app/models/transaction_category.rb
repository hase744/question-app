class TransactionCategory < ApplicationRecord
    belongs_to :category
    belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id, dependent: :destroy
end
