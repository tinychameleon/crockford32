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
  }

  ENCODE_SYMBOLS = {
    0 => '0',
    1 => '1',
    2 => '2',
    3 => '3',
    4 => '4',
    5 => '5',
    6 => '6',
    7 => '7',
    8 => '8',
    9 => '9',
    10 => 'A',
    11 => 'B',
    12 => 'C',
    13 => 'D',
    14 => 'E',
    15 => 'F',
    16 => 'G',
    17 => 'H',
    18 => 'J',
    19 => 'K',
    20 => 'M',
    21 => 'N',
    22 => 'P',
    23 => 'Q',
    24 => 'R',
    25 => 'S',
    26 => 'T',
    27 => 'V',
    28 => 'W',
    29 => 'X',
    30 => 'Y',
    31 => 'Z',
  }

  CHECKSUM_SYMBOLS = {
    '*' => 32,
    '~' => 33,
    '$' => 34,
    '=' => 35,
    'U' => 36, 'u' => 36,
  }

  DASH = '-'.freeze

  def self.decode(str)
    str.chars.each_with_index.reduce(0) do |result, ch_index|
      next result if ch_index[0] == DASH
      begin
        (result << 5) | DECODE_SYMBOLS.fetch(ch_index[0])
      rescue KeyError
        raise IllegalChecksumCharacterError.new(str, ch_index[1]) if CHECKSUM_SYMBOLS.key? ch_index[0]
        raise InvalidCharacterError.new(str, ch_index[1])
      end
    end
  end

  def self.encode(value, step: nil, length: nil)
    encode_number(
      case value
      when String
        value.bytes.map { |i| format("%02x", i) }.join.to_i(16)
      when Integer
        value
      else
        raise UnsupportedTypeError.new(value.class)
      end,
      step,
      length
    )
  end

  private

  def self.encode_number(number, step, length)
    result = ""
    index = 1
    loop do
      chunk = number & 0x1F
      result += ENCODE_SYMBOLS[chunk]
      result += DASH if step && index % step == 0
      number /= 0x20
      break if number == 0
      index += 1
    end

    if length
      raise LengthTooSmallError.new(number, result.length, length) if result.length > length
      result = result.ljust(length, "0") if length
    end
    result.reverse
  end
end
