module CommonMethods
  extend ActiveSupport::Concern
  def solve_n_plus_1(relation)
    case relation.klass.to_s
    when User.to_s then
      relation.includes(:categories, :user_categories)
    when Request.to_s then
      relation.includes(:user, :services, :request_categories, :categories, :items)
    when Service.to_s then
      relation.includes(:user, :requests, :categories, :service_categories, :transactions)
    when Transaction.to_s then
      relation.includes(:seller, :buyer, :request, :service, :items)
    end
  end
  
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
end