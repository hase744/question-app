module User::ServicesHelper
    def sales_number(service)
        service.stock_quantity + service.transactions.where(is_contracted:true, is_canceled:false, is_rejected:false).count
    end
end
