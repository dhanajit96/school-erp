# app/controllers/chats_controller.rb
class ChatsController < ApplicationController
  before_action :authenticate_user!

  def show
    @chat = Chat.find(params[:id])

    # Security: Ensure the current_user is one of the two participants
    redirect_to root_path, alert: "Access denied" unless [ @chat.user_one_id, @chat.user_two_id ].include?(current_user.id)

    @other_user = @chat.user_one == current_user ? @chat.user_two : @chat.user_one
    @messages = @chat.messages.includes(:user).order(created_at: :asc)
    @new_message = Message.new
  end
end
