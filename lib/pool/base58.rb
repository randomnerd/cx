class Pool::Base58
  @@alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  @@base = @@alphabet.size

  def self.encode(num)
    str = ''
    while num > @@base do
      mod = num % @@base
      str = @@alphabet[mod] + str
      num = (num - mod) / @@base
    end
    @@alphabet[num] + str
  end

  def self.decode(str)
    num = 0
    str.split('').reverse.each_with_index do |char, index|
      char_index = @@alphabet.index(char)
      raise 'Value passed is not a valid Base58 string.' unless char_index
      num += char_index * (@@base ** index)
    end
    return num
  end
end
