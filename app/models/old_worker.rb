class OldWorker
  include Mongoid::Document

  field :name, type: String
  field :pass, type: String
  field :userId, type: String
end
