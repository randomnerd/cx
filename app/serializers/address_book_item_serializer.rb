class AddressBookItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :updated_at, :created_at, :user_id, :currency_id
end
