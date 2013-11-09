class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency

  scope :currency, -> id { where(currency_id: id) }
end
