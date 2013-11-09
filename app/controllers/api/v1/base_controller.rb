class Api::V1::BaseController < InheritedResources::Base
  respond_to :json
  actions :index, :create, :update, :destroy, :show
  before_filter :authenticate_user!, except: [:index]

  def create
    @resource = build_resource
    @resource.user = current_user
    create!
  end

  protected
  def begin_of_association_chain
    @current_user
  end
end
