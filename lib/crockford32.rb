# frozen_string_literal: true

require_relative "crockford32/version"
require_relative "crockford32/errors"

module Crockford32
  ORDINALS = {"$"=>36,
 "*"=>42,
 "0"=>48,
 "1"=>49,
 "2"=>50,
 "3"=>51,
 "4"=>52,
 "5"=>53,
 "6"=>54,
 "7"=>55,
 "8"=>56,
 "9"=>57,
 "="=>61,
 "A"=>65,
 "B"=>66,
 "C"=>67,
 "D"=>68,
 "E"=>69,
 "F"=>70,
 "G"=>71,
 "H"=>72,
 "I"=>73,
 "J"=>74,
 "K"=>75,
 "L"=>76,
 "M"=>77,
 "N"=>78,
 "O"=>79,
 "P"=>80,
 "Q"=>81,
 "R"=>82,
 "S"=>83,
 "T"=>84,
 "U"=>85,
 "V"=>86,
 "W"=>87,
 "X"=>88,
 "Y"=>89,
 "Z"=>90,
 "a"=>97,
 "b"=>98,
 "c"=>99,
 "d"=>100,
 "e"=>101,
 "f"=>102,
 "g"=>103,
 "h"=>104,
 "i"=>105,
 "j"=>106,
 "k"=>107,
 "l"=>108,
 "m"=>109,
 "n"=>110,
 "o"=>111,
 "p"=>112,
 "q"=>113,
 "r"=>114,
 "s"=>115,
 "t"=>116,
 "u"=>117,
 "v"=>118,
 "w"=>119,
 "x"=>120,
 "y"=>121,
 "z"=>122,
 "~"=>126}
 DECODE_ARRAY = [nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 34,
 nil,
 nil,
 nil,
 nil,
 nil,
 32,
 nil,
 nil,
 nil,
 nil,
 nil,
 0,
 1,
 2,
 3,
 4,
 5,
 6,
 7,
 8,
 9,
 nil,
 nil,
 nil,
 35,
 nil,
 nil,
 nil,
 10,
 11,
 12,
 13,
 14,
 15,
 16,
 17,
 1,
 18,
 19,
 1,
 20,
 21,
 0,
 22,
 23,
 24,
 25,
 26,
 36,
 27,
 28,
 29,
 30,
 31,
 nil,
 nil,
 nil,
 nil,
 nil,
 nil,
 10,
 11,
 12,
 13,
 14,
 15,
 16,
 17,
 1,
 18,
 19,
 1,
 20,
 21,
 0,
 22,
 23,
 24,
 25,
 26,
 36,
 27,
 28,
 29,
 30,
 31,
 nil,
 nil,
 nil,
 33]

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

  DASH = '-'.ord.freeze

  def self.decode(value, as: :number, check: false)
    checksum = check ? value[-1] : nil
    value = check ? value[0...-1] : value
    value_index, shift_bits = -1, -0x05
    result = value.bytes.reduce(0) do |result, ch|
      value_index += 1
      next result if ch == DASH
      val = DECODE_ARRAY[ch.ord]
      raise InvalidCharacterError.new(value, value_index) if val.nil? || val >= 0x20
      shift_bits += 0x05
      result | (val << shift_bits)
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
      q, r = result.bit_length.divmod(0x08)
      q += 1 if r > 0
      bytes = Array.new(q)
      q.times { |i| bytes[i] = result & 0xff; result >>= 0x08 }
      bytes.pack('C*')
    else
      raise UnsupportedDecodingTypeError.new(as)
    end
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

  def self.encode_number(number, step, length, check)
    result = +""
    n = number
    index = 1
    loop do
      chunk = n & 0x1F
      result << ENCODE_SYMBOLS[chunk]
      result << DASH if step && index % step == 0
      n >>= 0x05
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

    result << ENCODE_SYMBOLS[number % 37] if check
    result
  end
end
