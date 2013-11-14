class Api::V1::BalanceChangesController < Api::V1::BaseController
  before_filter :authenticate_user!
  has_scope :currency
end
