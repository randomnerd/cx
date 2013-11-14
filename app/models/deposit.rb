class Deposit < ActiveRecord::Base
  belongs_to :user
  belongs_to :wallet
  belongs_to :currency

  scope :unprocessed, -> { where(processed: false) }
end
