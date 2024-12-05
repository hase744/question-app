module CommonMethods
  require 'nkf'
  attr_accessor :current_nav_item
  extend ActiveSupport::Concern

  def en_to_em(str)
    NKF.nkf('-w -Z4', str)
  end

  def half_size_kana(word)
    NKF.nkf('-w -Z4 -x', word.tr('あ-ん', 'ア-ン'))
  end

  def half_size_number(word)
    word.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')
  end

  def current_nav_item
    @current_nav_item
  end

  def set_current_nav_item
    @current_nav_item = params[:nav_item]
    @current_nav_item = controller_name if action_name == 'index'
    @current_nav_item ||= action_name
    @current_nav_item = 'posts' if @current_nav_item == 'show'
    @bar_elements = [
      {item:'requests', japanese_name: Request.model_name.human, link:user_requests_path(), page: @request_page, for_seller:false},
      {item:'transactions', japanese_name: Transaction.model_name.human, link:user_transactions_path(), page: @sales_page, for_seller:true},
      {item:'services', japanese_name: Service.model_name.human, link:user_services_path(), page: @service_page, for_seller:true},
      {item:'accounts',japanese_name: "回答者", link:user_accounts_path(), page:@review_page, for_seller:true},
    ]
  end

  def set_current_nav_item_for_service
    @current_nav_item = params[:nav_item]
    @current_nav_item ||= 'transactions'
  end

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

  def save_models
    models_to_save = [@service, @request, @transaction, @item, @items].flatten.compact
    models_to_save.all?(&:save)
  end

  def delete_temp_file_items
    @item&.delete_temp_file
    @items&.each do |item|
      item.delete_temp_file
    end
  end
end