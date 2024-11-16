require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "is not valid without an email" do
      user.email = nil
      user.valid? # エラーを発生させるためにvalid?を呼ぶ
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "is not valid without a password" do
      user.password = nil
      user.valid?
      expect(user.errors[:password]).to include("を入力してください")
    end

    it "is not valid if the email is already taken" do
      create(:user, email: "test@example.com")
      user.email = "test@example.com"
      user.valid?
      expect(user.errors[:email]).to include("はすでに存在します")
    end
  end

  describe "creating a user" do
    it "saves a valid user to the database" do
      expect { user.save }.to change { User.count }.by(1)
    end

    it "does not save an invalid user to the database" do
      user.email = nil
      expect { user.save }.not_to change { User.count }
    end
  end
end
