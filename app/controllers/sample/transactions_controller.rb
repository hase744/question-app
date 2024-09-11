class Sample::TransactionsController < Sample::Base
    layout "transaction_index", only: :index
    def index
        @seller = User.new(
          name: "ユーザー名"
          )
        @buyer = User.new(
          name: "ユーザー名"
          )
        @service = Service.new(
          user:@seller,
          title:"サービスのタイトル"
          )
        @request = Request.new(
          user: @buyer,
          title:"依頼のタイトル",
          description: @request_description
          )
        @request_item = RequestItem.new(
          request:@request,
          file:"https://corretech0625.s3.amazonaws.com/uploads/request/file/1/description_image202301222712.png"
          )
        @transaction = Transaction.new(
          id:0,
          title:"取引のタイトル",
          request:@request,
          service:@service,
          transacted_at: DateTime.now,
          delivery_form:Form.find_by(name:"image")
          )
        @delivery_item = DeliveryItem.new(
          deal:@transaction,
          thumbnail:"https://corretech0625.s3.amazonaws.com/uploads/transaction/file/1/description_image2023018132835.png",
          file:"https://corretech0625.s3.amazonaws.com/uploads/transaction/file/1/description_image2023018132835.png"
          )
        
        @transaction.set_item
        @transaction.file = @delivery_item.file
        @transaction.thumbnail = @delivery_item.thumbnail
        @transactions = [@transaction]
    end

    def show
        @og_image  = "https://corretech0625.s3.amazonaws.com/uploads/request/file/1/description_image202301222712.png"
        case params[:request_form]
        when "video" then
          video_form = Form.find_by(name:"video")
          @request.request_form = video_form
          @service.request_form = video_form
          @transaction.request_form = video_form
          @request_item.file = nil
          @request_item.youtube_id = "c5UkNCm_UWo"
          @request.file = nil
          @request.use_youtube = true
          @request.youtube_id = "c5UkNCm_UWo"
        when "image" then
          image_form = Form.find_by(name:"image")
          @request.request_form = image_form
          @service.request_form = image_form
          @transaction.request_form = image_form
          @request_item.thumbnail = "https://images.assetsdelivery.com/compings_v2/yupiramos/yupiramos1907/yupiramos190720042.jpg"
          @request_item.file = "https://images.assetsdelivery.com/compings_v2/yupiramos/yupiramos1907/yupiramos190720042.jpg"
        end

        case params[:delivery_form]
        when "video" then
          puts "ビデオ"
          video_form = Form.find_by(name:"video")
          @request.delivery_form = video_form
          @service.delivery_form = video_form
          @transaction.delivery_form = video_form
          @delivery_item.file = nil
          @delivery_item.youtube_id = "c5UkNCm_UWo"
          @transaction.youtube_id = "c5UkNCm_UWo"
          @transaction.file = nil
          @transaction.use_youtube = true
          @transaction.youtube_id = "c5UkNCm_UWo"
        when "image" then
          puts "イメージ"
          image_form = Form.find_by(name:"image")
          @request.delivery_form = image_form
          @service.delivery_form = image_form
          @transaction.delivery_form = image_form
          @delivery_item.thumbnail = "https://images.assetsdelivery.com/compings_v2/yupiramos/yupiramos1907/yupiramos190720042.jpg"
          @delivery_item.file = "https://images.assetsdelivery.com/compings_v2/yupiramos/yupiramos1907/yupiramos190720042.jpg"
        end
    end
end
