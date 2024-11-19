require 'rails_helper'

RSpec.describe Service, type: :model do
  let(:user2) { create(:user2) }

  describe "バリデーション" do
    let(:service) { build(:service, user: user2) }

    context "有効なデータの場合" do
      it "サービスが有効である" do
        service.title = "Test Title"
        service.description = "Test Description"
        service.price = 500
        service.delivery_days = 3
        service.service_categories.build(category_name: "business")
        expect(service).to be_valid
      end
    end

    context "タイトルが空の場合" do
      it "無効である" do
        service.title = nil
        expect(service).to_not be_valid
        expect(service.errors[:title]).to include("を入力してください")
      end
    end

    context "価格が100円単位でない場合" do
      it "無効である" do
        service.price = 550
        expect(service).to_not be_valid
        expect(service.errors[:price]).to include("は100円ごとにしか設定できません")
      end
    end

    context "価格が負の場合" do
      it "無効である" do
        service.price = -100
        expect(service).to_not be_valid
        expect(service.errors[:price]).to be_present
      end
    end

    context "カテゴリーが選択されていない場合" do
      it "無効である" do
        service.service_categories = []
        expect(service).to_not be_valid
        expect(service.errors[:base]).to include("カテゴリーが選択されていません")
      end
    end
  end
end
