require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user2) }

  describe "バリデーション" do
    it "すべての属性が正しい場合有効" do
      expect(user).to be_valid
    end

    it "メールアドレスがない場合無効" do
      user.email = nil
      user.valid? # エラーを発生させるためにvalid?を呼ぶ
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "パスワードがない場合無効" do
      user.password = nil
      user.valid?
      expect(user.errors[:password]).to include("を入力してください")
    end

    it "メールアドレスが既に存在している場合は無効" do
      create(:user, email: "test@example.com")
      user.email = "test@example.com"
      user.valid?
      expect(user.errors[:email]).to include("はすでに存在します")
    end
  end

  describe "ユーザーの作成" do
    it "有効なユーザーをデータベースに保存できる" do
      expect { user.save }.to change { User.count }.by(1)
    end

    it "無効なユーザーはデータベースに保存されない" do
      user.email = nil
      expect { user.save }.not_to change { User.count }
    end

    it "回答者になるには100字以上の自己紹介が必要" do
      user.description = ''
      user.save
      expect(user.errors.attribute_names).to include(:is_seller)
    end
  end
end
