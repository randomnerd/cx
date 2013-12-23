class Api::V2::BaseController < InheritedResources::Base
  respond_to :json
  actions :index, :create, :update, :destroy, :show
  before_filter :authenticate_user!, except: [:index]

  def create
    @resource = build_resource
    @resource.user = current_user
    binding.pry
    create!
  end
end
