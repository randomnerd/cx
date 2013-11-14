class Currency < ActiveRecord::Base
  has_many :incomes

  def rpc
    @rpc ||= CryptoRPC.new(self)
  end
end
