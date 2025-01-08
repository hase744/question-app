class ChatMessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
