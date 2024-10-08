module ApplicationHelper
include CommonMethods
include OperationConfig
include FormConfig
include Variables
  def from_now(datetime)
    if datetime == nil
      "-/-/--:--"
    else
      if datetime.to_s.include?("T") #DateTimeの表記方法の違いで分岐
        past_time = datetime.to_i - DateTime.now.to_i
      else
        past_time = datetime - DateTime.now#現在から何秒後
      end
      
      if 0 < past_time
        anterior_word = "あと"
        posterior_word = ""
      else
        anterior_word = ""
        posterior_word = "前"
      end

      difference = past_time.abs #絶対値
      minute = difference/60
      hour = minute/60
      day = hour/24
      week = day/7
      month = week/4
      year = day/365

      if (minute).to_i < 60#60分未満
        anterior_word + "#{minute.to_i }分" + posterior_word
      elsif hour.to_i < 24 #24時間未満
        anterior_word + "#{hour.to_i }時間" + posterior_word
      elsif day.to_i < 7 #７日未満
        anterior_word + "#{day.to_i}日" + posterior_word
      elsif week.to_i < 4 #4週間未満
        anterior_word + "#{week.to_i }週間" + posterior_word
      elsif  month.to_i < 12 #12ヶ月未満s
        anterior_word + "#{month.to_i }ヶ月" + posterior_word
      else
        anterior_word + "#{year.to_i}年" + posterior_word
      end
    end
  end

  def from_now_exact(datetime)
    if datetime == nil
      "-/-/--:--"
    else
      past_time = datetime.to_i - DateTime.now.to_i
      if 0 < past_time
        anterior_word = "あと"
        posterior_word = ""
      else
        anterior_word = ""
        posterior_word = "前"
      end
      
      difference = past_time.abs #絶対値
      minute = difference/60
      hour = minute/60
      day = hour/24
      week = day/7
      month = week/4
      year = day/365
      anterior_word + "#{day}日#{hour%24}時間#{minute%60}分" + posterior_word
    end
  end

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

  def user_image_default
    "/profile.jpg"
  end

  def minimum_total_reviews
    1
  end

  def convert_path(controller, action, id)
    {
      "contacts" => {"show" => user_contact_path(id)},
      "requests" => {"show" => user_request_path(id)},
      "transactions" => {"show" => user_transaction_path(id)},
      "services" => {"show" => user_service_path(id)}
    }[controller][action]
  end

  def notifications_length
    Notification.where(user_id: current_user.id, is_notified:false).length
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

  def category_select_hash
    Category.all.each_with_object({}) do |category, hash|
      hash[category.japanese_name] = category.name
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

  def javascript_path
    "#{controller_path}/#{action_name}.js"
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
end
