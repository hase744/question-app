module ChannelHandlers
  extend ActiveSupport::Concern
  included do
    before_action :check_current_action
  end

  def channel_controller_relationthip
    [
      {
        channel:'ChatMessagesChannel', 
        controllers:{
          allowed_controller_names: ['chat_messages', 'chat_destinations'],
          dismissed_controller_names: ['notficications']
        }
      }
    ]
  end

  def check_current_action
    @reload = false
    return unless user_signed_in?
    channel_controller_relationthip.each do |relationship|
      #WebSocketが許可されるべきコントローラーである
      if relationship[:controllers][:allowed_controller_names].include?(controller_name)
        unless current_user.connectable_channels.include?(relationship[:channel])
          current_user.connectable_channels.push(relationship[:channel])
          current_user.save
          @reload = true
        end
        next
      end
      unless current_user.connectable_channels.include?(relationship[:channel])
        current_user.connectable_channels.delete(relationship[:channel])
        current_user.save
      end
      #WebSocketが許可されるべきでないコントローラーである
      unless relationship[:controllers][:dismissed_controller_names].include?(controller_name)
        current_user.connectable_channels.delete(relationship[:channel])
        current_user.save
      end
    end
  end
end