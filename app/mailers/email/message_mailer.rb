class Email::MessageMailer < ApplicationMailer
    def receive(message, user)
        @message = message
        @uesr = user
        @contact = @message.room.contacts.find_by(user: @uesr)
        mail to: @message.receiver.email, subject: "DMが届いています"
    end
end
