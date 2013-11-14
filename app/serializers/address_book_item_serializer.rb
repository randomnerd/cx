class AddressBookItemSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :name, :address, :updated_at, :created_at, :user_id, :currency_id
end
