# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        # This looks for a file named create.turbo_stream.erb
        # If it doesn't exist, Rails 8 will just return a 204 No Content,
        # which is actually fine because the Model broadcast handles the update!
        # format.turbo_stream { render turbo_stream: turbo_stream.action(:append, "messages", partial: "messages/message", locals: { message: @message, is_current_user: true }) }
        format.turbo_stream { head :no_content }
        format.html { redirect_to chat_path(@chat) }
      end
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
