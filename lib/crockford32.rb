# frozen_string_literal: true

require_relative "crockford32/version"
require_relative "crockford32/errors"

module Crockford32
  DECODE_SYMBOLS = {
    '0' => 0, 'O' => 0, 'o' => 0,
    '1' => 1, 'I' => 1, 'i' => 1, 'L' => 1, 'l' => 1,
    '2' => 2,
    '3' => 3,
    '4' => 4,
    '5' => 5,
    '6' => 6,
    '7' => 7,
    '8' => 8,
    '9' => 9,
    'A' => 10, 'a' => 10,
    'B' => 11, 'b' => 11,
    'C' => 12, 'c' => 12,
    'D' => 13, 'd' => 13,
    'E' => 14, 'e' => 14,
    'F' => 15, 'f' => 15,
    'G' => 16, 'g' => 16,
    'H' => 17, 'h' => 17,
    'J' => 18, 'j' => 18,
    'K' => 19, 'k' => 19,
    'M' => 20, 'm' => 20,
    'N' => 21, 'n' => 21,
    'P' => 22, 'p' => 22,
    'Q' => 23, 'q' => 23,
    'R' => 24, 'r' => 24,
    'S' => 25, 's' => 25,
    'T' => 26, 't' => 26,
    'V' => 27, 'v' => 27,
    'W' => 28, 'w' => 28,
    'X' => 29, 'x' => 29,
    'Y' => 30, 'y' => 30,
    'Z' => 31, 'z' => 31,
    # Check Exclusive Symbols
    '*' => 32,
    '~' => 33,
    '$' => 34,
    '=' => 35,
    'U' => 36, 'u' => 36,
  }

  ENCODE_SYMBOLS = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'J',
    'K',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    # Check Exclusive Symbols
    '*',
    '~',
    '$',
    '=',
    'U',
  ].freeze

  DASH = '-'.freeze

  def self.decode(value, as: :number, check: false)
    value, checksum = check ? [value[0...-1], value[-1]] : [value, nil]
    result = value.chars.each_with_index.reduce(0) do |result, ch_index|
      next result if ch_index[0] == DASH
      val = DECODE_SYMBOLS[ch_index[0]]
      raise InvalidCharacterError.new(value, ch_index[1]) if val.nil? || val > 31
      (result << 5) | val
    end

    if check
      actual = result % 37
      required = DECODE_SYMBOLS[checksum]
      raise ChecksumError.new(value, actual, required) if actual != required
    end

    case as
    when :number
      result
    when :string
      q, r = result.bit_length.divmod(8)
      q += 1 if r > 0
      format("%0#{q * 8 >> 2}x", result).chars.each_slice(2).map { |a| a.join.to_i(16) }.pack('C*')
    else
      raise UnsupportedDecodingTypeError.new(as)
    end
  end

  def self.encode(value, step: nil, length: nil, check: false)
    encode_number(
      case value
      when String
        shift = 8 * (value.bytesize - 1)
        value.each_byte.reduce(0) do |n, b|
          x = b << shift
          shift -= 8
          n + x
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

  def self.encode_number(number, step, length, check)
    result = +(check ? ENCODE_SYMBOLS[number % 37] : "")
    index = check ? 2 : 1
    loop do
      chunk = number & 0x1F
      result << ENCODE_SYMBOLS[chunk]
      result << DASH if step && index % step == 0
      number /= 0x20
      break if number == 0
      index += 1
    end

    if length
      raise LengthTooSmallError.new(number, result.length, length) if result.length > length
      (length - result.length).times { result << +"0" } if length
    end
    result.reverse!
  end
end
