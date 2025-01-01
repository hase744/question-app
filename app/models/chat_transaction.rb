class ChatTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :chat_service
  belongs_to :messages
end
