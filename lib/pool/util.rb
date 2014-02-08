class Pool::Util

  def self.dblsha(data)
    digest1 = Digest::SHA2.new 256
    digest2 = Digest::SHA2.new 256
    digest1 << data
    digest2 << digest1.digest
    digest2.digest
  end

  def self.scrypt(data)
    Pool::Scrypt.scrypt_1024_1_1_256(data)
  end

  def self.ser_uint256(data, big_endian = false)
    fmt = big_endian ? "L>L>L>L>L>L>L>L>" : "L<L<L<L<L<L<L<L<"
    words = []
    8.times do
      words << (data & 0xFFFFFFFF)
      data >>= 32
    end
    return words.pack(fmt)
  end

  def self.deser_uint256(data, big_endian = false)
    fmt = big_endian ? "L>L>L>L>L>L>L>L>" : "L<L<L<L<L<L<L<L<"
    uint256 = 0
    data.unpack(fmt).each_with_index { |word, i| uint256 += word << i * 32 }
    shift(data, 32)
    return uint256
  end

  def self.hexlify(data)
    data.unpack('H*').first
  end

  def self.unhexlify(data)
    [data].pack('H*')
  end

  def self.reverse_bin(data, step = 1)
    return data.unpack('C*').reverse.pack('C*') if step == 1
    result = ''

    (data.bytesize / step).times do |i|
      chunk   = data.byteslice(i * step, step)
      result += reverse_bin chunk
    end
    return result
  end

  def self.uint256_from_compact(data)
    bytes = (data >> 24) & 0xFF
    (data & 0xFFFFFF) << 8 * (bytes - 3)
  end

  def self.reverse_hash(data)
    raise 'Wrong hash' unless data.bytesize == 64
    result = ''
    8.times { |i| result << data.byteslice(64 - (i+1)*8, 8) }
    return result
  end

  def self.ser_number(data)
    s = [1]
    while data > 127
      s[0] += 1
      s << data % 256
      data = (data / 256).floor
    end
    s << data
    s.pack 'C*'
  end

  def self.ser_buf_len(data)
    if data < 253
      [data].pack('C')
    elsif data < 0x10000
      [253].pack('C') + [data].pack('S<')
    elsif data < 0x100000000
      [254].pack('C') + [data].pack('L<')
    else
      [255].pack('C') + [data].pack('Q<')
    end
  end

  def self.deser_buf_len(data)
    len = shift(data, 1).unpack('C').first
    case len
    when 253 then len = shift(data, 2).unpack('S<').first
    when 254 then len = shift(data, 4).unpack('L<').first
    when 255 then len = shift(data, 8).unpack('Q<').first
    end
    return len
  end

  def self.ser_string(data)
    data ||= ''
    ser_buf_len(data.size) << data
  end

  def self.deser_string(data)
    len = deser_buf_len(data)
    return '' if len == 0
    shift(data, len)
  end

  def self.shift(data, bytes)
    bytes  = data.bytesize if bytes > data.bytesize
    result = data.byteslice(0, bytes)
    cutted = data.byteslice(bytes, data.bytesize - 1)
    data.replace(cutted) if cutted
    return result
  end

  def self.b58decode(str)
    hex = sprintf '%048x', Pool::Base58.decode(str)
    unhexlify(hex)
  end

  def self.address_to_pubkeyhash(addr)
    addr = b58decode(addr)
    raise 'Invalid address!' unless addr
    addr = unhexlify("00" + hexlify(addr)) if addr.bytesize == 24
    ver = addr.bytes.first

    cksumA = addr.byteslice(-4, addr.bytesize-1)
    cksumB = dblsha(addr.byteslice(0, addr.bytesize-4)).byteslice(0, 4)

    raise 'Address checksum didn`t match!' unless cksumA == cksumB
    [ver, addr.byteslice(1, addr.bytesize-5)]
  end

  def self.script_to_address(addr)
    ver, pubkeyhash = address_to_pubkeyhash(addr)
    unhexlify "76A914" + hexlify(pubkeyhash) + "88AC"
  end

  def self.script_to_pubkey(pubkey)
    if pubkey[0..1] == '04'
      result = "41"
    else
      result = "21"
    end
    result << pubkey
    result << "AC"
    unhexlify(result)
  end

  def self.ser_vector(data)
    result = ser_buf_len(data.size)
    data.each { |item| result << item.serialize }
    return result
  end

  def self.deser_vector(data, klass)
    len = deser_buf_len(data)
    result = []
    len.times do
      obj = klass.new
      obj.deserialize(data)
      result << obj
    end
    return result
  end
end
