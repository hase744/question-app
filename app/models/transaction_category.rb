class TransactionCategory < CategoryBase::Base
  belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id, dependent: :destroy
  delegate :user, to: :service
end