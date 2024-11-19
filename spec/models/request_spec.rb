require 'rails_helper'

RSpec.describe Request, type: :model do
  describe 'リクエストの公開' do
    context 'サービスがnilの場合' do
      let(:request) { build(:request, :without_service) }
      let(:request_text_item) { build(:request_text_item) }

      it '有効な属性であれば有効' do
        expect(request).to be_valid
      end

      it 'max_priceが設定されていない場合は無効' do
        request.max_price = nil
        expect(request).not_to be_valid
        expect(request.errors[:max_price]).to include("を設定してください")
      end

      it 'max_priceが最低値を下回る場合は無効' do
        request.max_price = 50
        expect(request).not_to be_valid
        expect(request.errors[:max_price]).to include("は100円以上に設定して下さい")
      end

      it 'max_priceが上限を超える場合は無効' do
        request.max_price = 20000
        expect(request).not_to be_valid
        expect(request.errors[:max_price]).to include("は10000円以下に設定して下さい")
      end
    end

    context 'リクエストが作成された場合' do
      it '複数のリクエストカテゴリがある場合は無効' do
        request = create(:request, :existing)
        request.request_categories << build(:request_category, request: request)
        request.request_categories << build(:request_category2, request: request)
        expect(request).not_to be_valid
        request.destroy
      end
    end
  
    context 'リクエストが公開された場合' do
      it '有効な属性であれば有効' do
        request = create(:request, :with_item)
        request.set_publish
        expect(request).to be_valid
      end
    end
  end

  describe 'サービス購入時' do
    let(:user) { create(:user) }
    let(:service_user) { create(:user2) }
    let(:request) { create(:exclusive_request, :with_item, user: user) }
    let(:service) { create(:service, :existing, user: service_user) }
    let(:transaction) { create(:transaction, request: request, service: service) }

    before do
      create(:payment_1000, user: request.user)
      request.service = service
      request.set_publish
      transaction.set_contraction
    end

    context 'サービスを購入する場合' do
      it '有効な属性であれば有効' do
        transaction.save
        request.save
        expect(request.user.total_points).to eq 0
        expect(transaction).to be_valid
        expect(request).to be_valid
      end

      it '複数のファイルがある場合は無効' do
        request.items << build(:request_text_item, request: request)
        expect(request).not_to be_valid
      end
    end
  end
end
