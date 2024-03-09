class Email::UserMailer < ApplicationMailer
    def revive(user)
        @token = user.reset_password_token
        @user = user
        mail to: user.email, subject: "アカウント再登録のための確認"
    end
end
