module ViewConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_selector
  end
  $selector = {
    '回答': "transaction", 
    '質問': "request", 
    '相談室': "service", 
    '回答者　　': "account"
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
  end

  $twitter_title = "コレテク　~ノウハウを売買するQAサイト~"
  $twitter_site = "$3UJVrqxCS0V4bin"
  $twitter_creator = "$3UJVrqxCS0V4bin"
  $og_title = "コレテク　~ノウハウを売買するQAサイト~"
  $og_url = "#{ENV['PROTOCOL']}://#{ENV['HOST']}"
  $og_description = "コレテクとはQ＆Aサイトとフリマサイトがお融合したサービスです。相談内容は公開され、誰でも閲覧できるのが特徴！登録して悩みを相談しよう！"
  $og_site_name = "コレテク"
  $og_image  = "#{ENV['PROTOCOL']}://#{ENV['HOST']}/corretech_large_icon.jpg"
  #$og_image  = "#{ENV['PROTOCOL']}://#{ENV['HOST']}/corretech_large_icon.jpg"
end