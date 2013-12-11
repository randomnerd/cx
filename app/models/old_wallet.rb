class OldWallet
  include Mongoid::Document
  store_in collection: "wallets"

  field :userId, type: String
  field :currId, type: String
  field :addr, type: String
end
