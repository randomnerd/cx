module Pool::Halfnode
class OutPoint
  attr_accessor :hash, :n

  def initialize
    @hash = 0
    @n = 0
  end

  def deserialize(data)
    @hash = Pool::Util.deser_uint256(data)
    @n = Pool::Util.shift(data, 4).unpack('L<')[0]
  end

  def serialize
    result  = Pool::Util.ser_uint256(@hash)
    result << [@n].pack('L<')
  end
end

class TransactionIn
  attr_accessor :prevout, :sequence, :scriptsig, :scriptsig_template

  def initialize
    @prevout = Pool::Halfnode::OutPoint.new
    @sequence = 0
    @scriptsig = ''
  end

  def deserialize(data)
    @prevout = Pool::Halfnode::OutPoint.new
    @prevout.deserialize(data)
    @scriptsig = Pool::Util.deser_string(data)
    @sequence = Pool::Util.shift(data, 4).unpack('L<')[0]
  end

  def serialize
    result  = @prevout.serialize
    result << Pool::Util.ser_string(@scriptsig)
    result << [@sequence].pack('L<')
  end
end

class TransactionOut
  attr_accessor :value, :script_pubkey

  def initialize
    @value = 0
    @script_pubkey = ''
  end

  def deserialize(data)
    @value = Pool::Util.shift(data, 8).unpack('Q<')[0]
    @script_pubkey = Pool::Util.deser_string(data)
  end

  def serialize
    result  = [@value].pack('Q<')
    result << Pool::Util.ser_string(@script_pubkey)
  end
end

class Transaction
  def initialize(pool)
    @time = 0
    @vin  = []
    @vout = []
    @pool = pool
    @sha256 = nil
    @version = @pool.tx_msg ? 2 : 1
    @message = ''
    @locktime = 0
  end

  def serialize
    result  = [@version].pack('L<')
    result << [@time].pack('L<') if @pool.pos
    result << Pool::Util.ser_vector(@vin)
    result << Pool::Util.ser_vector(@vout)
    result << [@locktime].pack('L<')
    result << Pool::Util.ser_string(@message) if @pool.tx_msg
    return result
  end

  def deserialize(data)
    @version  = Pool::Util.shift(data, 4).unpack('L<')[0]
    @time     = Pool::Util.shift(data, 4).unpack('L<')[0] if @pool.pos
    @vin      = Pool::Util.deser_vector(data, Pool::Halfnode::TransactionIn)
    @vout     = Pool::Util.deser_vector(data, Pool::Halfnode::TransactionOut)
    @locktime = Pool::Util.shift(data, 4).unpack('L<')[0]
    @message  = Pool::Util.deser_string(data) if @pool.tx_msg
    @sha256   = nil
  end

  def calc_sha256
    @sha256 = Pool::Util.dblsha(serialize)
  end

  def valid?
    calc_sha256
  end
end

class Block
  def initialize(pool)
    @pool = pool
    @version = 1
    @prevblock = 0
    @merkleroot = 0
    @time = 0
    @bits = 0
    @nonce = 0
    @tx = []
    @sha256 = nil
    @scrypt = nil
    @signature = ''
  end

  def deserialize(data)
    @version = Pool::Util.shift(data, 4).unpack('L<')[0]
    @prevblock = Pool::Util.deser_uint256(data)
    @merkleroot = Pool::Util.deser_uint256(data)
    @time = Pool::Util.shift(data, 4).unpack('L<')[0]
    @bits = Pool::Util.shift(data, 4).unpack('L<')[0]
    @nonce = Pool::Util.shift(data, 4).unpack('L<')[0]
    @tx = Pool::Util.deser_vector(data, Pool::Halfnode::Transaction)
    @signature = Pool::Util.deser_string(data) if @pool.pos
  end

  def serialize(full = true)
    result  = [@version].pack('L<')
    result << Pool::Util.ser_uint256(@prevblock)
    result << Pool::Util.ser_uint256(@merkleroot)
    result << [@time].pack('L<')
    result << [@bits].pack('L<')
    result << [@nonce].pack('L<')
    return result unless full
    result << Pool::Util.ser_vector(@tx)
    result << Pool::Util.ser_string(@signature) if @pool.pos
    return result
  end

  def calc_sha256
    data = serialize(false)
    @sha256 = Pool::Util.deser_uint256(Pool::Util.dblsha(data))
  end

  def calc_sha256_hex
    sprintf("%064x", calc_sha256)
  end

  def calc_scrypt
    data = serialize(false)
    @scrypt = Pool::Util.deser_uint256(Pool::Util.scrypt(data))
  end

  def calc_scrypt_hex
    sprintf("%064x", calc_scrypt)
  end

  def test
    block = {
        "hash" => "b652b05275671d831be7f74e828454f066735109edc56a82a0bb8f12e8cc7345",
        "confirmations" => 39,
        "size" => 10637,
        "height" => 443350,
        "version" => 2,
        "merkleroot" => "4ab9caed6b3dd001594746ad3cdc45aef363b4d0dde1fe34652125033fb6ecac",
        "transactions" => [
            {
                "data" => "010000000267612a1b4ca9c8f3df07f2d4fb245dd3658d5a41992179a6bf1c91baaa3d2c3c000000006c493046022100d89b990f027f3a79dd8490dc0c424294cb9d3949666594ef2573763c5d1eeffc022100cef54a614e832b26fc867da251616c1a0356959d220a7948e26062de91f240b3012102c64eb563138443007112172a6d241e04d214431477bff68b585995f9005a50fbffffffff939cd3f37eced87dd526d5def97d0a256c28313edde793108cac58b94db4f0cc000000006b48304502210089dd3ce38f4da896eee7335dab76a0a2f8ff56ccf7d1ea9bd453d4bdb920145502206c1978c3e3ad8ac4a9c66e059b84038a1c7db321c98fd377661d64171f0f88c90121030fae103e8193122dbdce92f048c491ef10a3cef95e3013bda03e2537d747a408ffffffff027582d118000000001976a914c473cbfc0a5ed0f264a05d6909b6872f8b3b0a5c88ac585b0441000000001976a914eef63ae397dc21706cfb78731aeffa6228ff083388ac00000000",
                "hash" => "8d111f7a30e595ce1899a2c682d5c52f7b5166d96c5e7111b7e17af4099d39f0",
                "fee" => 10000000,
                "depends" => [
                ],
                "sigops" => 2
            }
        ],
        "pos_transactions" => [
            {
                "data" => "010000008b3464520188a1d830f34c18ca114170dd39f2b140e38ff074090e93f3b5163042ad9e7677010000006b483045022064af40dd98a59678a08af8dd3923c3ccce0542e95b46c779b2e432a63b7c2e04022100f0eae4a61ffa6bf5e1f1ae60cd0598f4405c47b38f2b43f963493cb5081482fc0121031041bcbe3beb7b2d5bde701013a02ba2c6f8e9e4843ce2da153e175921f5242cffffffff0120f40e00000000001976a91401478397e81087aebeaac7e147bca5cd4ad4608b88ac00000000",
                "hash" => "d1919f556bb54da5e24751ca8aa3260128db4e30cdef581edc503b0446ffcfb0",
                "fee" => 16170,
                "depends" => [
                ],
                "sigops" => 1
            }
        ],
        "tx" => [
            "5169eba8477f35a4623198add6bb3c807aa9709a8e7f3456d72b7263423c8e8a",
            "ddacc4b8ca0c6450ed39668dbe6c872382c8c042933fd721fa0a0d21792a3c01"
        ],
        "time" => 1382005538,
        "nonce" => 2126383360,
        "bits" => "1b4239ec",
        "difficulty" => 989.56218648,
        "previousblockhash" => "01164c5a85643cd0e1a2ac0ad2c898713cac8394256f01a70d0173d96370719c",
        "nextblockhash" => "566fe5e4761e4ebc6028bd70cacaed54ea09fd0ae2bd8cf47d119a212df6a5ab"
    }
    @version = block['version']
    @prevblock = block['previousblockhash'].hex
    @merkleroot = block['merkleroot'].hex
    @time = block['time']
    @bits = block['bits'].hex
    @nonce = block['nonce']
    @hash = block['hash'].hex
    calc_scrypt
    target = Pool::Util.uint256_from_compact(@bits)
    hash = calc_sha256_hex
    raise 'Hash test failed' unless hash == block['hash']
    raise 'Target test failed' unless @scrypt < target

    txs = block['transactions']
    txs.each do |tx|
      t = Pool::Halfnode::Transaction.new(@pool)
      t.deserialize(Pool::Util.unhexlify(tx['data']))
      @tx << t
      ser = Pool::Util.hexlify(t.serialize)
      throw 'test failed, txlen' unless tx['data'].size == ser.size
      throw 'test failed, txdata' unless tx['data'] == ser
    end
  end

end
end
