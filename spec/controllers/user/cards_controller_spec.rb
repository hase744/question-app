require 'rails_helper'

RSpec.describe User::CardsController, type: :controller do
  let(:user) { create(:user, stripe_customer_id: 'cus_test123', stripe_card_id: 'card_test123') }

  before do
    sign_in user # Devise を使用している場合のログインヘルパー
  end

  describe 'GET #show' do
    context 'ユーザーがカードを登録している場合' do
      before do
        # Stripe::Customer.retrieve_source のモックを設定
        allow(Stripe::Customer).to receive(:retrieve_source).with(
          user.stripe_customer_id,
          user.stripe_card_id
        ).and_return(
          'id' => 'card_test123',
          'brand' => 'Visa',
          'last4' => '4242',
          'exp_month' => 12,
          'exp_year' => 2024
        )
      end

      it 'Stripe からカード情報を取得する' do
        get :show

        expect(assigns(:card)).to include(
          'id' => 'card_test123',
          'brand' => 'Visa',
          'last4' => '4242',
          'exp_month' => 12,
          'exp_year' => 2024
        )
      end

      it 'show テンプレートをレンダリングする' do
        get :show
        expect(response).to render_template(:show)
      end
    end

    context 'ユーザーがカードを登録していない場合' do
      before do
        user.update(stripe_customer_id: nil, stripe_card_id: nil)
      end

      it '@card に nil が割り当てられる' do
        get :show
        expect(assigns(:card)).to be_nil
      end
    end
  end
end
