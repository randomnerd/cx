class Api::V2::BaseController < InheritedResources::Base
  respond_to :json
  actions :index, :create, :update, :destroy, :show
  before_filter :authenticate_user!, except: [:index]
  before_filter :set_user, only: [:create]

  def index
    render json: FastJson.dump(collection)
  end

  def set_user
    @resource = build_resource
    @resource.user = current_user
  end
end
