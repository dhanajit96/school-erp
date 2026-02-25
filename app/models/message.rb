class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat

  # This triggers the real-time broadcast via Solid Cable
  after_create_commit -> {
    broadcast_append_to chat,
    target: "messages",
    partial: "messages/message",
    locals: { message: self, is_current_user: false }
  }
end
