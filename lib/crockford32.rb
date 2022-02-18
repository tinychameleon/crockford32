# frozen_string_literal: true

require_relative "crockford32/version"
require_relative "crockford32/errors"

module Crockford32
  ENCODED_BITS = 0x05
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
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
    'G', 'H', 'J', 'K', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z',
    '*', '~', '$', '=', 'U'
  ].freeze
  # standard:enable Layout/ExtraSpacing,Layout/ArrayAlignment

  def self.decode(value, as: :number, check: false)
    checksum = check ? value[-1] : nil
    value = check ? value[0...-1] : value
    value_index, shift_bits = -1, -ENCODED_BITS
    result = value.bytes.reduce(0) do |result, ch|
      value_index += 1
      next result if ch == DASH
      val = DECODE_ORDINALS[ch.ord]
      raise InvalidCharacterError.new(value, value_index) if val.nil? || val >= 0x20
      shift_bits += ENCODED_BITS
      result | (val << shift_bits)
    end

    if check
      actual = result % CHECKSUM_PRIME
      required = DECODE_ORDINALS[checksum.ord]
      raise ChecksumError.new(value, actual, required) if actual != required
    end

    into_type as, result
  end

  def self.encode(value, step: nil, length: nil, check: false)
    encode_number(
      case value
      when String
        q, r = value.bytesize.divmod(8)
        if r == 0
          n = 0
          bytes = value.bytes
          while q > 0
            s = (q - 1) * 0x40
            i = q * 0x08
            n += bytes[i - 1] << (s + 0x38)
            n += bytes[i - 2] << (s + 0x30)
            n += bytes[i - 3] << (s + 0x28)
            n += bytes[i - 4] << (s + 0x20)
            n += bytes[i - 5] << (s + 0x18)
            n += bytes[i - 6] << (s + 0x10)
            n += bytes[i - 7] << (s + 0x08)
            n += bytes[i - 8] << (s + 0x00)
            q -= 1
          end
          n
        else
          shift = -0x08
          value.each_byte.reduce(0) do |n, b|
            shift += 0x08
            n + (b << shift)
          end
        end
      when Integer
        value
      else
        raise UnsupportedEncodingTypeError.new(value.class)
      end,
      step,
      length,
      check,
    )
  end

  private

  def self.into_type(type, result)
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
    q.times { |i| bytes[i] = result & 0xff; result >>= 0x08 }
    bytes.pack('C*')
  end

  def self.encode_number(number, step, length, check)
    result = +""
    n = number
    index = 1
    loop do
      chunk = n & 0x1F
      result << ENCODE_SYMBOLS[chunk]
      result << DASH if step && index % step == 0
      n >>= ENCODED_BITS
      index += 1
      break if n == 0
    end

    rlen = result.length + (check ? 1 : 0)
    if length
      raise LengthTooSmallError.new(number, rlen, length) if rlen > length
      length -= 1 if check
      while result.length < length
        result << +"0"
        break if result.length == length
        result << DASH if step && index % step == 0
        break if result.length == length
        index += 1
      end
    end

    result << ENCODE_SYMBOLS[number % CHECKSUM_PRIME] if check
    result
  end
end
