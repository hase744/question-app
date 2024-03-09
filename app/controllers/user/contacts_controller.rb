class User::ContactsController < User::Base
  before_action  :check_login,  only:[:index, :show, :create]
  before_action :check_relatiohship, only:[:show]
  def index
    @contacts = Contact.includes(:room, :destination).where(user_id: current_user.id).order(updated_at: :asc).page(params[:page]).per(15)
  end

  def show
    destination_id = params[:destination_id]
    @messages = []
    @contacts = Contact.includes(:room, :destination).where(user_id: current_user.id).order(updated_at: :asc).page(params[:page]).per(15)
    if destination_id
      @contact = Contact.new(user_id: current_user.id, destination_id: params[:destination_id])
    else
      @contact = Contact.find_by(id:params[:id], user_id:current_user.id)
    end
    if @contact.user == current_user
      @room = @contact.room
      @user = @contact.user
      @message = Message.new()
      if @room
        puts @room.id
        messages = Message.includes(:receiver, :sender).where(room_id:@room.id).limit(15).order(id: "DESC")
        #配列を作成し表示する順番を逆にする

        messages.each do |m|
          @messages.unshift(m)
        end
        messages.includes(:receiver).where(receiver: current_user, is_read:false).each do |message|
          message.update(is_read: true) #既読にする
        end
      end
    end
  end

  def cells
    @contacts = Contact.includes(:room, :destination).where(user_id: current_user.id).order(updated_at: :asc).page(params[:page]).per(15)
    render partial: 'user/contacts/cells_block', locals: { contacts: @contacts }
  end

  def personal_config
  end

  def new
    contact = Contact.new(user_id, current_user.id)
    redirect_to user_contact_path(contact.id)
  end

  private def identify_user
    contact = Contact.find(params[:id])
    if contact
      if contact.user != current_user
        redirect_to user_contacts_path
      end
    end
  end
  
  private def check_relatiohship
    if Contact.exists?(id:params[:id], user:current_user)
      destination_id = Contact.find_by(id:params[:id], user:current_user).destination_id
    else
      destination_id = params[:destination_id]
    end

    if !message_receivable(User.find(destination_id))
      flash.notice = "メッセージを送信できません"
      redirect_to user_account_path(destination_id)
    end
  end
end
