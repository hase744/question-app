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

  def translate(word)
    if word
      word_array = word.split(",")
      all_words = ""
      
      word_array.each do |w|
        if all_words == ""
          all_words += translate_list(w.delete(" "))
        else
          all_words += ", "
          all_words += translate_list(w.delete(" "))
        end
      end
      all_words
    else
      word
    end
  end

  def notifications_length
    Notification.where(user_id: current_user.id, is_notified:false).length
  end

  def can_purchase
    if !user_signed_in?
      true
    #サインインしている && サービスが公開 && 在庫がある
    elsif user_signed_in? && (@service.is_published && (@service.stock_quantity == nil || @service.stock_quantity > 0 ))
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
      if transaction.is_delivered
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

  def message_receivable(user)
    if user_signed_in?
      if Relationship.exists?(followee:user, follower:current_user, is_blocked:true)
        false
      elsif user.can_receive_message
        true
      elsif Contact.exists?(user:user, destination: current_user)
        true
      else
        false
      end
    elsif user.can_receive_message
      true
    else
      false
    end
  end

  def shared_paths
    Dir.glob("app/javascript/packs/shared/*.js")  do |path|
      path.slice(21, path.length).to_s
    end
  end

  def unit
  end
end
