class ChatService < ApplicationRecord
  belongs_to :user
  attr_accessor :buyer
  has_many :chat_transactions
  enum type_name: {
    one_time: 0,
    one_week: 1,
    one_month: 2,
    unlimited: 3
  }
  validate :set_default_value

  def set_default_value
    if self.type_name == 'one_time'
      self.limit = nil
    end
  end
  
  def limit_display(user)
    transactions = chat_transactions
      .where(buyer: user)
      .usable
      .includes(:chat_messages)
    puts transactions.count

    total_remaining_count = transactions.sum { |tx| tx.remaining_count.to_i }
    tx = pick_display_transaction(transactions)
    return "" if tx.nil?

    case type_name
    when 'one_time'
      "残り#{total_remaining_count}回"
    when 'one_week'
      remaining_time_display(tx, unit_label: "週間")
    when 'one_month'
      remaining_time_display(tx, unit_label: "ヶ月")
    end
    #self.limit == 0 ? '送り放題' : "回まで"
  end

  def pick_display_transaction(transactions)
    transactions.min_by do |t|
      t.expires_at ? t.expires_at.to_i : (Time.current + 100.years).to_i
    end
  end

  def remaining_time_display(tx, unit_label:)
    if tx.started_at.nil?
      # 「初回メッセージ起点」仕様なので、未開始の場合はこの表示がわかりやすい
      #"(未開始：初回メッセージから#{tx.count}#{unit_label}有効)"
      "未使用"
    else
      sec = tx.remaining_seconds
      "残り#{format_duration(sec)}"
    end
  end

  def format_duration(seconds)
    seconds = seconds.to_i
    days = seconds / 86_400
    hours = (seconds % 86_400) / 3_600
    mins = (seconds % 3_600) / 60

    if days > 0
      "#{days}日#{hours}時間"
    elsif hours > 0
      "#{hours}時間#{mins}分"
    else
      "#{mins}分"
    end
  end

  def price_options
    (price_minimum_number..price_max_number)
      .step(100)
      .map { |num| 
        if num == 0
          ["#{num}円（お試し）", num]
        else
          ["#{num}円", num]
        end
      }
  end

  def limit_options
    (0..1000)
      .step(50)
      .map { |num| 
        if num == 0
          ['無制限', num]
        else
          ["#{num}回", num]
        end
      }
  end

  def coupon_user
    self.buyer
  end

  def total_price
    self.price
  end

  def price_minimum_number
    100
  end

  def price_max_number
    10000
  end

  def self.selector_hash
    I18n.t('activerecord.attributes.chat_service/type_name').invert
  end

  def type_name_japanese
    I18n.t("activerecord.attributes.chat_service/type_name.#{type_name}")
  end
end
