class ChatMessagesChannel < ApplicationCable::Channel
  def subscribed
    unless allowed_to_subscribe?(current_user)
      reject
    end
    stream_for current_user
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def allowed_to_subscribe?(user)
    return false unless current_user
    if current_user.connectable_channels.include?(self.class.name)
      return true
    end
    false
  end
end
