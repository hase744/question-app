require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'when buying services' do
    let(:transaction) { create(:transaction, :contracted) }
    #let(:request) { transaction.request }

    context '納品する場合' do
      it '適切な属性の場合は有効' do
        transaction.title = "Sample Transaction."
        transaction.description = "This is a description for the sample transaction."
        transaction.set_delivery
        expect(transaction.buyer.total_points).to eq 0
        expect(transaction).to be_valid
      end
    end

    context 'キャンセルする場合' do
      before do
        transaction.set_cansel
      end

      it '納品期限が過ぎている場合は有効 ' do
        transaction.delivery_time = DateTime.now - 1
        transaction.save
        expect(transaction.buyer.total_points).to eq 1000
        expect(transaction).to be_valid
      end

      it '納品期限が過ぎていない場合は無効 ' do
        expect(transaction.buyer.total_points).to eq 0
        expect(transaction).not_to be_valid
      end
    end
  end
end