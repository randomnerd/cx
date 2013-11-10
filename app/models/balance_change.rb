class BalanceChange < ActiveRecord::Base
  belongs_to :balance
  belongs_to :subject, polymorphic: true
end
