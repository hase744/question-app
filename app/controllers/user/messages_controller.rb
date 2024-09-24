class User::MessagesController < User::Base
  before_action :check_login
  def show
    messages = Message.includes(:sender, :receiver).order(created_at: "DESC").where(room_id: params[:room_id]).page(params[:page]).per(15)
    #配列に前から入れることで順番を逆にする
    @messages = []
    messages.each do |m|
      @messages.unshift(m)
      end
    messages.where(receiver: current_user, is_read:false).each do |message|
      message.update(is_read: true) #既読にする
    end
    render partial: "user/messages/message_cells", locals: {messages: @messages}
  end

  def create
    receiver_id = params[:message][:receiver_id]
    contact = Contact.find_by(user:current_user, destination_id: receiver_id)
    #contactが存在するか
    if contact
      @message = Message.new(message_params)
      @message.sender_id = current_user.id
      @message.room_id = contact.room.id
      @message.contact = contact
      if @message.save
        puts "保存"
        room = Room.find(contact.room_id)
        room.last_message = @message.body
        room.last_message_at = DateTime.now
        if room.save
          puts "last_message更新"
          if Message.where(sender:current_user, )
            create_notification(@message)
            send_email
          end
        else
          puts "last_message更新に失敗"
        end
      else
        puts "メッセージエラー"
      end
      redirect_to user_contact_path(contact.id)
    else
      room = Room.new()
      if room.save
        puts "ルーム作成"
      else
        puts "ルーム作成失敗"
      end

      sender_contact = Contact.new(user_id: current_user.id, destination_id: receiver_id, room_id: room.id)
      receiver_contact = Contact.new(user_id: receiver_id, destination_id: current_user.id, room_id: room.id)

      if sender_contact.save && receiver_contact.save
        contact = sender_contact
        @message = Message.new(message_params)
        @message.sender_id = current_user.id
        @message.room_id = contact.room.id
        if @message.save
          puts "メッセージ保存"
          room.last_message = @message.body
          room.last_message_at = DateTime.now
          if room.save
            puts "last_message更新"
            create_notification(@message)
            send_email
          else
            puts "last_message更新に失敗"
          end
        else
          puts "メッセージ保存に失敗"
        end
        redirect_to user_contact_path(sender_contact.id)
      else
        puts "sender_contact作成失敗"
      end
    end
  end

  def send_email
    if @message.receiver.can_receive_message
      #Email::MessageMailer.receive(@message, current_user).deliver_now
    end
  end

  def create_notification(message)
    puts "通知作成"
    Notification.create(
      user_id: @message.receiver_id,
      notifier_id: @message.sender_id,
      title: "メッセージをが届いています",
      description: @message.body,
      action: "show",
      controller: "contacts",
      id_number: Contact.find_by(room: Room.find(@message.room_id).id, user_id: @message.receiver_id).id
      )
  end

  private def message_params
    params.require(:message).permit(
      :body,
      :file,
      :receiver_id
    )
  end
end
