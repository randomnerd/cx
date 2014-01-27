class Api::V2::AddressBookItemsController < Api::V2::BaseController
  def create
    item = current_user.address_book_items.create(permitted_params[:address_book_item])
    render json: {
      address_book_items: [AddressBookItemSerializer.new(item)]
    }
  end

  protected
  def begin_of_association_chain
    current_user
  end

  def permitted_params
    params.permit(address_book_item: [:currency_id, :name, :address])
  end
end
