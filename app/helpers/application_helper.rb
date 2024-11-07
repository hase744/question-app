module ApplicationHelper
include CommonMethods
include FormConfig
include Variables
include OperationConfig
  def readable_datetime(datetime)
    if datetime
      datetime.strftime("%Y/%m/%d %H:%M")
    else
      "-/-/- -:-"
    end
  end

  def from_now_day(datetime)
    "#{datetime.strftime('%d')}"
  end

  def minimum_total_reviews
    1
  end

  def main_path(request)
		if request.is_published
			user_request_path(request.id)
    else
			user_request_preview_path(request.id, transaction_id: request.transaction&.id)
		end
  end

  def notifications_length
    Notification.published.where(user_id: current_user.id, is_notified:false).length
  end

  def can_purchase
    if !user_signed_in?
      true
    #サインインしている && サービスが公開 && 在庫がある
    elsif user_signed_in? && (@service.is_published && @service.is_for_sale)
      #出品者でない
      if @service.user != current_user
        true
      else
        puts "買えない"
        false
      end
    end
  end

  def request_completed
    transaction = Transaction.find_by(request_id: @request.id)
    if transaction
      if transaction.is_transacted
        true
      else
        false
      end
    else
      false
    end
  end

  def shared_paths
    Dir.glob("app/javascript/packs/shared/*.js")  do |path|
      path.slice(21, path.length).to_s
    end
  end

  def mime_types_from_extensions(extensions)
    extensions.map { |ext| "image/#{ext}" }.join(', ')
  end

  def accept_image
    mime_types_from_extensions(FileUploader.new.image_extensions)
  end

  def sorts_manager
    {
      likes_count: {japanese_name: 'いいねが多い', name: 'likes_count'},
      followers_count: {japanese_name: 'フォロワーが多い', name: 'followers_count'},
      published_at: {japanese_name: '投稿が新しい', name: 'published_at'},
      deadline: {japanese_name: '受付期限が近い', name: 'deadline'},
      popularity: {japanese_name: '人気', name: 'popularity'},
      max_price: {japanese_name: '予算が多い', name: 'max_price'},
      price: {japanese_name: '価格が安い', name: 'price'},
      transactions_count: {japanese_name: '回答が多い', name: 'transactions_count'},
      suggestions_count: {japanese_name: '提案数が少ない', name: 'transactions_count'},
    }
  end

  def account_sort_list
    [:followers_count, :transactions_count]
  end

  def service_sort_list
    [:likes_count, :transactions_count, :price]
  end

  def transaction_sort_list
    [:likes_count, :published_at]
  end

  def request_sort_list
    [:likes_count, :max_price, :suggestions_count, :published_at, :deadline]
  end

  def sort_options(list)
    list.each_with_object({}) do |sort_key, result|
      info = sorts_manager[sort_key]
      result[info[:japanese_name]] = info[:name] if info
    end
  end

  def discounted_price(service)
    return unless user_signed_in?
    transaction = service.transactions.new(
      service: service,
      request: Request.new,
      price: service.price,
      buyer: current_user
    )
    transaction.required_points
  end
end
