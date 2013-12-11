class OldWorker
  include Mongoid::Document
  store_in collection: "workers"

  field :name, type: String
  field :pass, type: String
  field :userId, type: String
end
