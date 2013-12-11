class OldBalance
  include Mongoid::Document
  store_in collection: "balances"

  field :balance, type: Integer
  field :held, type: Integer
  field :currId, type: String
  field :userId, type: String
end
