class User::AccountsController < User::Base
  before_action :check_login, only:[:edit, :update]
  before_action :check_published, only: [:show]
  before_action :define_page_count
  before_action :define_models, only: [:show, :posts, :requests, :sales, :services, :reviews]
  after_action :create_access_log
  layout :choose_layout

  private def choose_layout
    case action_name
    when 'edit'
      'medium_layout'
    when "index"
      "search_layout"
    end
  end

  def index
    @users = User.all
    @users = @users.is_sellable
    @users = @users.where("name LIKE?", "%#{params[:name]}%")
    @users = @users.order(total_sales_numbers: :desc)
    @users = @users.filter_categories(params[:categories])
    @users = @users.solve_n_plus_1
    @users = @users.include_price
    
    #if params[:total_sales_numbers].present? && @users.present?
    #  #@users = @users.where("total_sales_numbers >= ?", params[:total_sales_numbers])
    #end

    if params[:elapsed_days].present?
      @requests = @requests.where("suggestion_deadline > ?", DateTime.parse(params[:suggestion_deadline]) - 30)
    end

    @users = @users.page(params[:page]).per(10)

    gon.layout = "action_index"
  end

  def edit
    @user = current_user
    gon.text_max_length = @user.description_max_length
    
    @categories = Category.all #config.jsonにある親カテゴリー
  end

  def show
    @user = User.find(params[:id])
    @bar_elements = [
      {item:'posts', japanese_name:'Q&A', link:user_account_posts_path(@user.id, nav_item:'posts'), page: @post_page, for_seller:false},
      {item:'requests', japanese_name:'質問', link:user_account_requests_path(@user.id, nav_item:'requests'), page: @request_page, for_seller:false},
      {item:'sales', japanese_name:'回答', link:user_account_sales_path(@user.id, nav_item:'sales'), page: @sales_page, for_seller:true},
      {item:'services', japanese_name:Service.model_name.human, link:user_account_services_path(@user.id, nav_item:'services'), page: @service_page, for_seller:true},
      {item:'reviews',japanese_name:'レビュー', link:user_account_reviews_path(@user.id, nav_item:'reviews'), page:@review_page, for_seller:true},
    ]

    current_element = @bar_elements.find{|e| 
      e[:item] == current_nav_item
    }

    @relationship = Relationship.find_by(user: @user, target_user_id: current_user.id) if user_signed_in?
    if @user == current_user
      gon.tweet_text = "#{@user.name}という名前でコレテクを始めました。"
    else
      gon.tweet_text = "#{@user.name}さんのコレテクアカウントはこちら。気になる方は以下のリンクへ！"
    end
    if @user.image.url
      @og_image = @user.image.url
    end
    @og_title = @user.name
    @og_description = @user.description
  end

  def update
    @user = current_user
    @user.process_image_upload = true
    @user.process_header_image_upload = true
    @user.assign_attributes(user_params)

    if @user.save
        flash.notice = "ユーザー情報を更新しました"
        redirect_to user_account_path(@user.id)
    else
        @categories = Category.all
        gon.text_max_length = @user.description_max_length
        render action: "edit"
    end
  end

  def services
    render partial: 'user/services/cell', collection: @services, as: :service
  end
  #@services.page(params[:page]).includes(:user).per(10)
  def posts
    #@posts = Post.where(user_id: params[:id]).includes(:user).order(id: :DESC).page(params[:page]).per(@post_page)
    #@models.each do |item|
    #  if item.is_a?(Request)
    #    render partial: 'user/requests/cell', locals: { request: item }
    #  elsif item.is_a?(Transaction)
    #    render partial: 'user/transactions/cell', locals: { transaction: item }
    #  end
    #end
    #render partial: 'user/posts/cell', collection: @posts, as: :post
    render partial: 'user/accounts/posts', locals: { models: @models}
  end

  def purchases
    purchases = Transaction.left_joins(:request).where(request: {user_id: params[:id]}, is_published: true).includes(:buyer, :seller, :request, :service, :items).order(id: :DESC)
    @purchases = purchases.page(params[:page]).per(5)
    render partial: "user/accounts/transactions", locals: { contents: @purchases }
  end

  def sales
    render partial: 'user/transactions/answer', collection: @models, as: :transaction
  end

  def requests
    render partial: 'user/requests/question', collection: @models, as: :request
  end

  def users
    relationships = Relationship.where(target_user_id: params[:id]).order(id: :DESC).order(id: :DESC)
    @relationships = relationships.page(params[:page]).per(5)
    
    user_ids = []
    @relationships.each do |relationship|
      user_ids.push(relationship.user_id)
    end

    @users = User.where(id: user_ids)
    render partial: "user/accounts/users", locals: { contents: @users }
  end

  def reregister
    @user = User.find_by(email: params[:user][:email])
    if @user.present? && @user.is_deleted
        @user.reset_password_token = SecureRandom.alphanumeric
        if @user.save
            flash.alert = "再登録のためメールを送信しました"
            Email::UserMailer.revive(@user).deliver_now
            redirect_to new_user_registration_path
        else
            flash.alert = "再登録のためメールを送信できませんでした"
            redirect_to new_user_registration_path
        end
    else
      flash.alert = "アカウントが見つかりませんでした"
      redirect_to user_renew_account_path
    end
  end
  
  def reviews
    render partial: 'user/reviews/cell', collection: @models, as: :transaction
  end

  def renew
    @user = User.new
  end

  def revive
    user = User.find_by(reset_password_token: params[:reset_password_token], is_deleted:true)

    if user.present? && user.update(is_deleted:false, reset_password_token:nil)
      flash.notice = "アカウントが再登録されました"
      redirect_to new_user_session_path
    else
      flash.notice = "アカウントが再登録できませんでした"
      redirect_to user_renew_account_path
    end
  end

  private def define_page_count
    @post_page = 5
    @request_page = 5
    @sales_page = 5
    @service_page = 20
    @review_page = 5
  end

  private def define_models
    params[:page] ||= 1
    case current_nav_item
    when 'posts'
      transaction_sql = <<-SQL
      SELECT 'Transaction' AS record_type, id, created_at, published_at 
      FROM transactions
      WHERE seller_id = #{ActiveRecord::Base.connection.quote(params[:id])}
        AND is_published = true
      SQL

      request_sql = <<-SQL
      SELECT 'Request' AS record_type, id, created_at, published_at 
      FROM requests
      WHERE user_id = #{ActiveRecord::Base.connection.quote(params[:id])}
        AND is_published = true
      SQL

      final_sql = <<-SQL
      (#{transaction_sql})
      UNION ALL
      (#{request_sql})
      ORDER BY published_at DESC
      LIMIT #{@post_page} OFFSET #{(params[:page].to_i-1)*@post_page}
      SQL

      records = ActiveRecord::Base.connection.execute(final_sql)
      requests = Request.solve_n_plus_1.find(records.map{|row| row['id'] if row['record_type'] == 'Request'}.compact).to_a
      transactions = Transaction.solve_n_plus_1.find(records.map{|row| row['id'] if row['record_type'] == 'Transaction'}.compact).to_a
      records = records.to_a
      records.map! do |row|
        case row['record_type']
        when 'Transaction'
          row = transactions.find { |model| model['id'] == row['id'] }
        when 'Post'
          row = posts.find { |model| model['id'] == row['id'] }
        when 'Request'
          row = requests.find { |model| model['id'] == row['id'] }
        end
        row # 変更されたrecordを返す
      end
      @models = records
    when 'requests'
      @models = Request
        .where(user_id: params[:id], is_published: true)
        .page(params[:page])
        .per(@request_page)
    when 'sales'
      @models = Transaction
        .from_seller(User.find(params[:id]))
        .where(is_published: true)
        .page(params[:page])
        .per(@sales_page)
        .order(id: :DESC)
    when 'services'
      @models = Service.solve_n_plus_1
        .where(user_id: params[:id], request_id: nil)
        .displayable(current_user)
        .page(params[:page])
        .per(@service_page)
    when 'reviews'
      @models = Transaction
        .from_seller(User.find(params[:id]))
        .where(is_transacted: true)
        .where.not(reviewed_at: nil)
        .page(params[:page])
        .per(@review_page)
    end
  end

  private def check_published
    @user = User.find(params[:id])
    if !@user.is_published
      flash.notice = "アカウントはは非公開です"
      redirect_to user_accounts_path
    elsif @user.is_suspended || @user.is_deleted
      flash.notice = "アカウントはは存在しません"
      redirect_to user_accounts_path
    end
  end

  private def user_params
    params.require(:user).permit(
        :name, 
        :description, 
        :image, 
        :header_image
    )
  end
end
