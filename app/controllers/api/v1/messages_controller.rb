class Api::V1::MessagesController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!, except: [:index]

  def index
    respond_with Message.recent
  end

  def create
    current_user.messages.create(params[:message].permit(:body))
    head :no_content
  end
end
