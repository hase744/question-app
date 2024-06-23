module ViewConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_selector
  end
  $selector = {
    '回答': "transaction", 
    '質問': "request", 
    '相談室': "service", 
    '回答者': "account"
  }
  #コントローラー名とオプションのペア
  $options = {
    'services' => 'service',
    'requests' => 'request',
    'accounts' => 'account',
    'transactions' => 'transaction',
  }

  private

  def set_selector
    if $options.keys.include?(controller_name)
      $selected = $options[controller_name]
    else
      $selected = 'transaction'
    end

    case controller_name
    when "requests" then
      $model = Request.new
    when "services" then
      $model = Service.new
    when "accounts" then
      $model = User.new
    else
      $model = Transaction.new(service: Service.new)
    end
  end

  $twitter_title = "コレテク　~稼げるQ&Aサイト~"
  $twitter_site = "$3UJVrqxCS0V4bin"
  $twitter_creator = "$3UJVrqxCS0V4bin"
  $og_title = "コレテク　~稼げるQ&Aサイト~"
  $og_url = "#{ENV['PROTOCOL']}://#{ENV['HOST']}"
  $og_description = "コレテクとはQ＆Aサイトとフリマサイトがお融合したサービスです。質問と回答のマーケットプレイス！登録して悩みを相談しよう！"
  $og_site_name = "コレテク"
  @og_image  = "#{ENV['PROTOCOL']}://#{ENV['HOST']}/corretech_large_icon.jpg"
  #@og_image  = "#{ENV['PROTOCOL']}://#{ENV['HOST']}/corretech_large_icon.jpg"
end