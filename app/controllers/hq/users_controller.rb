class Hq::UsersController < Hq::BaseController
  include ActionView::Helpers::DateHelper
  has_scope :filter_query
  def index
    @users = collection.order('created_at desc')
  end

  def ban
    time = params[:minutes].try(:minutes)
    time ||= 60.minutes
    wtime = time_ago_in_words(Time.at(Time.now + time))
    resource.update_attribute :banned_until, Time.at(Time.now + time).utc
    redirect_to :back, notice: "User ##{resource.id} (#{resource.nickname}) has been banned for #{wtime}"
  end

  def unban
    resource.update_attribute :banned_until, nil if resource.banned?
    redirect_to :back, notice: "User ##{resource.id} (#{resource.nickname}) has been unbanned"
  end

  def resend_confirmation
    resource.send_confirmation_instructions
    redirect_to :back, notice: "Confirmation email has been sent to #{resource.email}"
  end
end
