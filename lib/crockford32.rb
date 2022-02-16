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

  CHECKSUM_SYMBOLS = {
    '*' => 32,
    '~' => 33,
    '$' => 34,
    '=' => 35,
    'U' => 36, 'u' => 36,
  }

  def self.decode(str)
    str.chars.each_with_index.reduce(0) do |result, ch_index|
      begin
        (result << 5) | DECODE_SYMBOLS.fetch(ch_index[0])
      rescue KeyError
        raise IllegalChecksumCharacterError.new(str, ch_index[1]) if CHECKSUM_SYMBOLS.key? ch_index[0]
        raise InvalidCharacterError.new(str, ch_index[1])
      end
    end
  end
end
