class OldOrder
  include Mongoid::Document

  field :pairId, type: String
  field :userId, type: String
  field :complete, type: Boolean
  field :cancelled, type: Boolean
  field :fee, type: Float
  field :filled, type: Integer
  field :amount, type: Integer
  field :rate, type: Integer
  field :timestamp, type: DateTime
  field :bid, type: Boolean
end
