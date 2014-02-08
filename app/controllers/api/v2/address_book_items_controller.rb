class Api::V2::AddressBookItemsController < Api::V2::BaseController
  protected
  def begin_of_association_chain
    current_user
  end

  def permitted_params
    params.permit(address_book_item: [:currency_id, :name, :address])
  end
end
