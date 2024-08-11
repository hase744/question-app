module CommonMethods
  attr_accessor :current_nav_item
  extend ActiveSupport::Concern

  def en_to_em(str)
    NKF.nkf('-w -Z4', str)
  end

  
  def translate_list(word)
    {
      "video" => "動画",
      "image"=> "画像",
      "text" => "文章",
      "advisement"=>"相談",
      "consult"=>"相談",
      "career"=>"キャリア",
      "business"=>"ビジネス",
      "paid"=>"完了",
      "pending"=>"準備中",
      "in_transit"=>"送金中",
      "canceled"=>"キャンセル",
      "failed"=>"失敗",
    }[word.to_s]
  end

  def current_nav_item
    @current_nav_item
  end

  def set_current_nav_item
    @current_nav_item = params[:nav_item]
    @current_nav_item ||= 'posts'
  end

  def set_current_nav_item_for_service
    @current_nav_item = params[:nav_item]
    @current_nav_item ||= 'transactions'
  end
end