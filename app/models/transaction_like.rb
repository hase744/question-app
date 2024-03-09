class TransactionLike < ApplicationRecord
  belongs_to :user
  belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id
end
