class Pool::Coinbaser
  def initialize(pool)
    @pool = pool
    @address = pool.mining_address
  end

  def get_script_pubkey
    if @pool.pos
      Pool::Util.script_to_pubkey(@address)
    else
      Pool::Util.script_to_address(@address)
    end
  end

  def get_coinbase_data
    return '' # stub
  end
end
