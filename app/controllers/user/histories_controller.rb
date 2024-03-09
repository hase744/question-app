class User::HistoriesController < User::Base
  before_action :check_login
  def index
    @transactions = Transaction.includes(:items, :service, request: [:items])
    if params[:deal] == "purchase"
      @transactions = @transactions.left_joins(:request, :items)
      @transactions = @transactions.where(request: {user: current_user}, is_delivered:true)
    else
      @transactions = @transactions.left_joins(:service, :items)
      @transactions = @transactions.where(service: {user: current_user}, is_delivered:true)
    end
    @transactions = @transactions.page(params[:page]).per(10)
  end

  def show
  end

  def create
  end

end
