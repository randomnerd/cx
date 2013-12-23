class Hq::BaseController < InheritedResources::Base
  before_filter :check_admin
  layout 'hq'

  def check_admin
    redirect_to root_path unless current_user.try(:admin?)
  end

  def collection
    end_of_association_chain.paginate(page: params[:page], per_page: 100)
  end
end
