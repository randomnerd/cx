class Hq::UsersController < Hq::BaseController
  has_scope :filter_query
  def index
    @users = collection
  end

  def ban
    time = params[:minutes].try(:minutes)
    time ||= 60.minutes
    resource.update_attribute :banned_until, Time.at(Time.now + time).utc
    redirect_to :back
  end

  def unban
    resource.update_attribute :banned_until, nil if resource.banned?
    redirect_to :back
  end
end
