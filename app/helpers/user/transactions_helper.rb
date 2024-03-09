module User::TransactionsHelper
    def can_deliver(transaction)
        if transaction.is_canceled
            false
        elsif transaction.is_rejected
            false
        elsif transaction.is_delivered
            false
        else
            true
        end
    end
end
