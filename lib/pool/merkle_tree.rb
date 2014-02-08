class Pool::MerkleTree
  attr_accessor :steps
  def initialize(data, detailed = false)
    @data = data
    recalculate(detailed)
    @sha_steps = nil
  end

  def recalculate(detailed = false)
    l = @data
    steps = []
    if detailed
      prel = []
      detail = []
      startl = 0
    else
      prel = [nil]
      detail = nil
      startl = 2
    end

    ll = l.size
    if detailed || ll > 1
      while true do
        detail.push(l) if detailed
        break if ll == 1
        steps.push(l[1])
        l.push(l[ll-1]) if ll.odd?

        arr = [prel]
        (startl..ll).step(2) do |i|
          break unless l[i] && l[i+1]
          arr.push(Pool::Util.dblsha(l[i] + l[i+1]))
        end
        l = arr
        ll = l.size
      end
    end

    @steps = steps
    @detail = detail
  end

  def hash_steps
    @sha_steps ||= Pool::Util.dblsha
  end

  def with_first(data)
    @steps.each { |step| data = Pool::Util.dblsha(data + step) }
    return data
  end

  def merkle_root
    with_first(@data.first)
  end

  def self.test
    arr = [nil] + [
      '999d2c8bb6bda0bf784d9ebeb631d711dbbbfe1bc006ea13d6ad0d6a2649a971',
      '3f92594d5a3d7b4df29d7dd7c46a0dac39a96e751ba0fc9bab5435ea5e22a19d',
      'a5633f03855f541d8e60a6340fc491d49709dc821f3acb571956a856637adcb6',
      '28d97c850eaf917a4c76c02474b05b70a197eaefb468d21c22ed110afe8ec9e0'
    ].map { |hash| Pool::Util.unhexlify(hash) }

    mt = new(arr)
    a = '82293f182d5db07d08acf334a5a907012bbb9990851557ac0ec028116081bd5a'
    b = Pool::Util.unhexlify('d43b669fb42cfa84695b844c0402d410213faa4f3e66cb7248f688ff19d5e5f7')
    raise 'Test failed' unless a == Pool::Util.hexlify(mt.with_first(b))
  end
end
