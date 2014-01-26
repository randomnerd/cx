class Pool::BlockTemplate < Pool::Halfnode::Block
  attr_accessor :job_id, :target, :curtime, :submits, :merkletree,
                :prevhash_hex, :broadcast_args, :tx
  def initialize(pool, job_id)
    @pool = pool
    @job_id = job_id
    @target = 0
    @curtime = 0
    @submits = {}
    @timedelta = 0
    @merkletree = nil
    @broadcast_args = []
  end

  def fill_from_rpc(data, coinbaser_extras = '/stratumPool/')
    @txhashes = [nil]

    data['transactions'].each do |tx|
      @txhashes << Pool::Util.ser_uint256(tx['hash'].hex)
    end

    @bits = data['bits'].hex
    @height = data['height']
    @version = data['version']
    @curtime = data['curtime']
    @timedelta = @curtime - Time.now.to_i
    @prevblock = data['previousblockhash'].hex
    @merkletree = Pool::MerkleTree.new(@txhashes)
    @target = Pool::Util.uint256_from_compact(@bits)

    coinbase = Pool::CoinbaseTX.new(
      @pool, data['coinbasevalue'], data['coinbaseaux']['flags'],
      @height, coinbaser_extras, data['curtime']
    )

    @tx = [ coinbase ]
    data['transactions'].each do |tx|
      @tx << Pool::Halfnode::Transaction.new(@pool).deserialize(Pool::Util.unhexlify(tx['data']))
    end

    @prevhash_bin = Pool::Util.unhexlify(Pool::Util.reverse_hash(data['previousblockhash']))
    @prevhash_hex = data['previousblockhash']

    @broadcast_args = build_broadcast_args
  end

  def register_submit(*params)
    username = params.delete_at 0
    @submits[username] ||= []
    return false if @submits[username].include? params
    @submits[username] << params
  end

  def build_broadcast_args
    prevhash = Pool::Util.hexlify @prevhash_bin
    coinb1 = Pool::Util.hexlify(@tx.first.serialized.first)
    coinb2 = Pool::Util.hexlify(@tx.first.serialized.last)
    merkle_branch = []
    @merkletree.steps.each { |step| merkle_branch << Pool::Util.hexlify(step) }
    version = Pool::Util.hexlify([@version].pack('L>'))
    time = Pool::Util.hexlify([@curtime].pack('L>'))
    bits = Pool::Util.hexlify([@bits].pack('L>'))
    clean_jobs = true

    [
      @job_id, prevhash, coinb1, coinb2, merkle_branch,
      version, bits, time, clean_jobs
    ]
  end

  def serialize_coinbase(en1, en2)
    part1, part2 = @tx.first.serialized
    part1 + en1 + en2 + part2
  end

  def check_time(time)
    return false if time < @curtime
    return false if time > (Time.now + 2.hours).to_i
    return true
  end

  def serialize_header(merkleroot_int, time_bin, nonce_bin)
    data =  [@version].pack('L>')
    data << @prevhash_bin
    data << Pool::Util.ser_uint256(merkleroot_int, true)
    data << time_bin
    data << [@bits].pack('L>')
    data << nonce_bin
  end

  def finalize(merkleroot_int, extranonce1_bin, extranonce2_bin, time, nonce)
    @time = time
    @nonce = nonce
    @merkleroot = merkleroot_int
    @tx.first.set_extra_nonce(extranonce1_bin + extranonce2_bin)
    @sha256 = nil
    @scrypt = nil
  end

  def valid?
    true # stub
  end
end
