module Pool::Scrypt

  def scrypt_1024_1_1_256(input)
    input = [input].pack('H*') if input.bytesize == 160
    scrypt_1024_1_1_256_sp(input)
  end

  def scrypt_1024_1_1_256_sp(input, scratchpad = [])
    b = pbkdf2_sha256(input, input, 1, 128)
    x = b.unpack('V*')
    v = scratchpad

    1024.times do |i|
      v[ ( i * 32 ) ... ( ( i * 32 ) + 32 ) ] = x.dup
      xor_salsa8(x, x,  0, 16)
      xor_salsa8(x, x, 16,  0)
    end

    1024.times do |i|
      j = 32 * (x[16] & 1023)
      32.times { |k| x[k] ^= v[j+k] }
      xor_salsa8(x, x,  0, 16)
      xor_salsa8(x, x, 16,  0)
    end

    pbkdf2_sha256(input, x.pack("V*"), 1, 32)
  end

  def pbkdf2_sha256(pass, salt, c = 1, dk_len = 128)
    raise "pbkdf2_sha256: wrong length." if pass.bytesize != 80 or ![80,128].include?(salt.bytesize)
    raise "pbkdf2_sha256: wrong dk length." if ![128,32].include?(dk_len)
    if RUBY_PLATFORM == 'java'
      Krypt::PBKDF2.new(Krypt::Digest::SHA256.new).generate(pass, salt, c, dk_len)
    else
      OpenSSL::PKCS5.pbkdf2_hmac(pass, salt, c, dk_len, OpenSSL::Digest::SHA256.new)
    end
  end

  def rotl(a, b)
    a &= 0xffffffff
    ((a << b) | (a >> (32 - b))) & 0xffffffff
  end

  def xor_salsa8(a, b, a_offset, b_offset)
    x = 16.times.map{|n| a[a_offset+n] ^= b[b_offset+n] }

    4.times do
      [
        [ 4,  0, 12,  7], [ 9,  5,  1,  7],  [14, 10,  6,  7], [ 3, 15, 11,  7],
        [ 8,  4,  0,  9], [13,  9,  5,  9],  [ 2, 14, 10,  9], [ 7,  3, 15,  9],
        [12,  8,  4, 13], [ 1, 13,  9, 13],  [ 6,  2, 14, 13], [11,  7,  3, 13],
        [ 0, 12,  8, 18], [ 5,  1, 13, 18],  [10,  6,  2, 18], [15, 11,  7, 18],

        [ 1,  0,  3,  7], [ 6,  5,  4,  7],  [11, 10,  9,  7], [12, 15, 14,  7],
        [ 2,  1,  0,  9], [ 7,  6,  5,  9],  [ 8, 11, 10,  9], [13, 12, 15,  9],
        [ 3,  2,  1, 13], [ 4,  7,  6, 13],  [ 9,  8, 11, 13], [14, 13, 12, 13],
        [ 0,  3,  2, 18], [ 5,  4,  7, 18],  [10,  9,  8, 18], [15, 14, 13, 18]
      ].each{ |i| x[ i[0] ] ^= rotl(x[ i[1] ] + x[ i[2] ], i[3]) }
    end

    16.times{ |n| a[a_offset+n] = (a[a_offset+n] + x[n]) & 0xffffffff }
    true
  end

  extend self
end
