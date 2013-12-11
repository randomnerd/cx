class OldWallet
  include Mongoid::Document

  field :userId, type: String
  field :currId, type: String
  field :addr, type: String
end
