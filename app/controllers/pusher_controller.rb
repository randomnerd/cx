class PusherController < ApplicationController
  protect_from_forgery except: :auth # stop rails CSRF protection for this action

  def auth
    if current_user
      cuid = params[:channel_name].match(/private-.*-(\d)/).try(:[], 1)
      if cuid && current_user.id != cuid.to_i
        render text: "Forbidden", status: '403'
        return
      end

      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
        user_id: current_user.id,
        user_info: {
          name: current_user.nickname
        }
      })
      render json: response
    else
      render text: "Forbidden", status: '403'
    end
  end
end
