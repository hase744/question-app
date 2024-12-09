require 'rails_helper'

RSpec.describe User::ServicesController, type: :controller do
  let(:user2) { create(:user2) }
  let(:request) { create(:request, :with_item) }
  let(:service) { create(:service, user: user2) }

  before do
    request.set_publish
    request.save
    sign_in user2 # Devise を使用している場合のログインヘルパー
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        service: {
          title: '仕事の悩み相談',
          description: '専門的なアドバイスや解決策を提供し、悩みや疑問に対してリアルタイムでサポートします。豊富な経験をもとに、仕事に関する様々なテーマに対応可能です。進行中のプロジェクトやキャリアに関する相談から、スキルの向上やキャリアアドバイスまで、あらゆる仕事に関するトピックに対応いたします。プロフェッショナルな助言で仕事に自信を持ち、成功への一歩を踏み出しましょう。安心して相談できるプライベートな空間で、あなたの仕事に関する課題を共有し、解決に導くお手伝いを致します。',
          service_categories_attributes: {
            "0" => { category_name: 'business' }
          },
          request_form_name: 'text',
          request_max_characters: '0',
          delivery_form_name: 'text',
          transaction_message_enabled: 'true',
          price: '100',
          delivery_days: '1',
          allow_pre_purchase_inquiry: 'true',
          is_published: 'true',
          is_for_sale: 'true'
        }
      }
    end

    let(:invalid_attributes) do
      {
        service: {
          title: nil, # 無効なデータ
          description: nil,
          service_categories_attributes: {},
        }
      }
    end

    context '相談室の作成' do
      it '適切な属性の相談室の作成' do
        expect {
          post :create, params: valid_attributes
        }.to change(Service, :count).by(1)
        expect(response).to have_http_status(:found)
      end

      it 'タイトルなし属性の相談室の作成' do
        post :create, params: valid_attributes.deep_merge(service: {title:nil})
        expect(response).to render_template("user/services/new")
      end
    end

    context '相談室の提案不適切な属性の相談室の提案' do
      before do
        valid_attributes[:service][:request_id] = request.id
      end

      it '適切な属性の相談室の提案' do
        expect {
          post :create, params: valid_attributes
        }.to change(Service, :count).by(1)
        expect(response).to have_http_status(:found)
      end

      it 'タイトルなし属性の相談室の提案' do
        post :create, params: valid_attributes.deep_merge(service: {title:nil})
        expect(response).to render_template("user/services/new")
      end
    end
  end

  describe 'PUT #suggest' do
    context '相談室の提案' do
      it '適切な相談室を提案した時、Transactionが増える' do
        allow_any_instance_of(User).to receive(:is_stripe_customer_valid?).and_return(true)
        expect {
          put :suggest, params: {id: service.id, request_id: request.id}
        }.to change(Transaction, :count).by(1)
      end

      it '自由形式で相談室を提案した時、Transactionが増える' do
        service.request_form_name = 'free'
        service.save
        allow_any_instance_of(User).to receive(:is_stripe_customer_valid?).and_return(true)
        expect {
          put :suggest, params: {id: service.id, request_id: request.id}
        }.to change(Transaction, :count).by(1)
      end

      it '質問形式の違う相談室を提案した時、Transactionが増えない' do
        service.request_form_name = 'image'
        service.save
        allow_any_instance_of(User).to receive(:is_stripe_customer_valid?).and_return(true)
        expect {
          put :suggest, params: {id: service.id, request_id: request.id}
        }.to change(Transaction, :count).by(0)
      end
    end
  end
end
