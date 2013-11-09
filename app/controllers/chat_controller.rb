class ChatController < ApplicationController
  def index
    @messages = Message.recent
  end
end
