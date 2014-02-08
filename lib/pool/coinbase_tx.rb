class Pool::CoinbaseTX < Pool::Halfnode::Transaction
  attr_accessor :serialized

  def initialize(pool, value, flags, height, data, time)
    super(pool)
    @time = time
    @pool = pool

    extranonce_ph = Pool::Util.unhexlify('f000000ff111111f')
    extranonce_size = 8

    txin = Pool::Halfnode::TransactionIn.new
    txin.prevout.hash = 0
    txin.prevout.n = 2**32 - 1
    txin.scriptsig_template = []

    tmpl1  = Pool::Util.ser_number(height)
    tmpl1 << Pool::Util.unhexlify(flags)
    tmpl1 << Pool::Util.ser_number(Time.now.to_i)
    tmpl1 << [extranonce_size].pack('C*')

    txin.scriptsig_template << tmpl1
    txin.scriptsig_template << Pool::Util.ser_string(@pool.coinbaser.get_coinbase_data + data)
    txin.scriptsig = txin.scriptsig_template.first + extranonce_ph + txin.scriptsig_template.last

    txout = Pool::Halfnode::TransactionOut.new
    txout.value = value
    txout.script_pubkey = @pool.coinbaser.get_script_pubkey

    @vin << txin
    @vout << txout

    @serialized = serialize.split(extranonce_ph)
  end

  def set_extra_nonce(extranonce)
    part1, part2 = @vin.first.scriptsig_template
    @vin.first.scriptsig = part1 + extranonce + part2
  end
end
