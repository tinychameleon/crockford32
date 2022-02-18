# frozen_string_literal: true

require_relative "crockford32/version"
require_relative "crockford32/errors"

module Crockford32
  ENCODED_BITS = 0x05
  CHECK_SYMBOL_MIN_VALUE = 0x20
  CHECKSUM_PRIME = 0x25
  DASH = "-".ord.freeze

  # standard:disable Layout/ExtraSpacing,Layout/ArrayAlignment
  DECODE_ORDINALS = [
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
     34, nil, nil, nil, nil, nil,  32, nil, nil, nil, nil, nil,
      0,   1,   2,   3,   4,   5,   6,   7,   8,   9, nil, nil,
    nil,  35, nil, nil, nil,  10,  11,  12,  13,  14,  15,  16,
     17,   1,  18,  19,   1,  20,  21,   0,  22,  23,  24,  25,
     26,  36,  27,  28,  29,  30,  31, nil, nil, nil, nil, nil,
    nil,  10,  11,  12,  13,  14,  15,  16,  17,   1,  18,  19,
      1,  20,  21,   0,  22,  23,  24,  25,  26,  36,  27,  28,
     29,  30,  31, nil, nil, nil,  33
  ].freeze

  ENCODE_SYMBOLS = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F",
    "G", "H", "J", "K", "M", "N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z",
    "*", "~", "$", "=", "U"
  ].freeze
  # standard:enable Layout/ExtraSpacing,Layout/ArrayAlignment

  def self.decode(value, into: :number, check: false)
    checksum = check ? value[-1] : nil
    value = check ? value[0...-1] : value

    result = le_decode_number value

    if check
      actual = result % CHECKSUM_PRIME
      required = DECODE_ORDINALS[checksum.ord]
      raise ChecksumError.new(value, actual, required) if actual != required
    end

    convert result, into
  end

  def self.encode(value, length: nil, check: false)
    le_encode_number(raw_value_to_number(value), length, check)
  end

  # lksdjflsad

  def self.le_decode_number(encoded_value)
    symbol = -1
    bits = -ENCODED_BITS
    encoded_value.bytes.reduce(0) do |result, ch|
      symbol += 1
      next result if ch == DASH
      val = DECODE_ORDINALS[ch.ord]
      raise InvalidCharacterError.new(encoded_value, symbol) if val.nil? || val >= CHECK_SYMBOL_MIN_VALUE
      bits += ENCODED_BITS
      result | (val << bits)
    end
  end

  def self.convert(result, type)
    case type
    when :number
      result
    when :string
      into_string result
    else
      raise UnsupportedDecodingTypeError.new(type)
    end
  end

  def self.into_string(result)
    q, r = result.bit_length.divmod(0x08)
    q += 1 if r > 0
    bytes = Array.new(q)
    q.times do |i|
      bytes[i] = result & 0xff
      result >>= 0x08
    end
    bytes.pack("C*")
  end

  def self.raw_value_to_number(value)
    case value
    when String
      q, r = value.bytesize.divmod(8)
      if r == 0
        string_to_number_unrolled value, q
      else
        string_to_number value
      end
    when Integer
      value
    else
      raise UnsupportedEncodingTypeError.new value.class
    end
  end

  def self.string_to_number(s)
    shift = -0x08
    s.each_byte.reduce(0) do |n, b|
      shift += 0x08
      n + (b << shift)
    end
  end

  def self.string_to_number_unrolled(s, iterations)
    n = 0
    bytes = s.bytes
    while iterations > 0
      o = (iterations - 1) * 0x40
      i = iterations * 0x08
      n += bytes[i - 1] << (o + 0x38)
      n += bytes[i - 2] << (o + 0x30)
      n += bytes[i - 3] << (o + 0x28)
      n += bytes[i - 4] << (o + 0x20)
      n += bytes[i - 5] << (o + 0x18)
      n += bytes[i - 6] << (o + 0x10)
      n += bytes[i - 7] << (o + 0x08)
      n += bytes[i - 8] << (o + 0x00)
      iterations -= 1
    end
    n
  end

  def self.le_encode_number(number, length, check)
    result = +""
    n = number
    loop do
      chunk = n & 0x1F
      result << ENCODE_SYMBOLS[chunk]
      n >>= ENCODED_BITS
      break if n == 0
    end

    rlen = result.length + (check ? 1 : 0)
    if length
      raise LengthTooSmallError.new(number, rlen, length) if rlen > length
      result << "0" * (length - rlen)
    end

    result << ENCODE_SYMBOLS[number % CHECKSUM_PRIME] if check
    result.freeze
  end

  private_class_method [:le_decode_number, :convert, :into_string, :raw_value_to_number,
    :string_to_number, :string_to_number_unrolled, :le_encode_number]
end
