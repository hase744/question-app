class Sample::AccountsController < Sample::Base
  layout "search_layout", only: :index
  def index
    @users = [@seller]
  end

  def show
    @user = @seller
  end
end
