require 'rails_helper'

RSpec.describe User::RequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:file_path) { Rails.root.join('spec/fixtures/test.jpg') }
  let(:uploaded_file) { Rack::Test::UploadedFile.new(file_path, 'image/jpg') }

  before do
    sign_in user # Devise を使用している場合のログインヘルパー
  end


  before do
    allow(Stripe::Customer).to receive(:retrieve_source).and_return(
      OpenStruct.new(cvc_check: 'pass') # モックされたStripeのレスポンス
    )
  end

  describe 'POST #create #publish' do
    let(:valid_attributes) do
      {
        request: {
          title: '仕事に対するモチベーション',
          description: '最近、仕事に対するモチベーションが低下しています。やりがいを感じられず、将来への不安が募っています。今の仕事を続けるべきか、それとも新しい道を模索すべきか悩んでいます。同じ環境でのルーティンに疲れ、新しい挑戦を求めていますが、安定感も捨てがたいです。どのようにして自分に合った仕事を見つけ、人生をより充実させることができるでしょうか？仕事と生活のバランスを取りながら、将来の展望を見据えるためのステップは何でしょうか？ご助言いただければ幸いです。',
          request_categories_attributes: {
            "0" => { category_name: 'business' }
          },
          mode: 'proposal',
          request_form_name: 'text',
          request_max_characters: '0',
          delivery_form_name: 'text',
          transaction_message_enabled: 'true',
          max_price: '100',
          reward: '100',
          suggestion_acceptable_days: 1,
        }
      }
    end

    let(:valid_publish_attributes) do
      {
        request: {
        }
      }
    end

    let(:invalid_attributes) do
      {
        request: {
          title: nil, # 無効なデータ
          description: nil,
          service_categories_attributes: {},
        }
      }
    end

    context '質問の作成' do
      it '相談室募集の質問の公開' do
        expect {
          post :create, params: valid_attributes
        }.to change(Request, :count).by(1)
        expect(response).to have_http_status(:found)
        redirect_url = response.location
        id = redirect_url.match(%r{/requests/(\d+)}).captures.first
        request_model = Request.find(id)
        expect(response).to redirect_to(user_request_preview_path(request_model))

        valid_publish_attributes[:id] = id
        valid_publish_attributes[:request][:file] = uploaded_file
        
        expect {
          post :publish, params: valid_publish_attributes
        }.to change(Request, :count).by(0)
        request_model = Request.find(id)
        expect(request_model.is_published).to eq(true)
        expect(request_model.published_at).not_to be_nil
        expect(response).to redirect_to(user_request_path(request_model))
      end

      it '回答募集の質問の公開' do
        valid_attributes[:request][:mode] = 'reward'
        expect {
          post :create, params: valid_attributes
        }.to change(Request, :count).by(1)
        expect(response).to have_http_status(:found)
        redirect_url = response.location
        id = redirect_url.match(%r{/requests/(\d+)}).captures.first
        request_model = Request.find(id)
        expect(response).to redirect_to(user_request_preview_path(request_model))

        valid_publish_attributes[:id] = id
        valid_publish_attributes[:request][:file] = uploaded_file
        
        expect {
          post :publish, params: valid_publish_attributes
        }.to change(Request, :count).by(0)
        request_model = Request.find(id)
        expect(request_model.is_published).to eq(true)
        expect(request_model.published_at).not_to be_nil
        expect(response).to redirect_to(user_request_path(request_model))
      end
    end
  end
end
