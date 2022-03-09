# frozen_string_literal: true

require_relative "crockford32/version"
require_relative "crockford32/errors"

# A fast little-endian implementation of {https://www.crockford.com/base32.html Douglas Crockford’s Base32 specification}.
#
# @since 1.0.0
module Crockford32
  # The number of bits encoded per symbol.
  ENCODED_BITS = 0x05

  # The minimum value of a check symbol.
  CHECK_SYMBOL_MIN_VALUE = 0x20

  # The prime number used to implement error detection.
  CHECKSUM_PRIME = 0x25

  # The ordinal value of an ASCII dash character.
  DASH = "-".ord.freeze

  # standard:disable Layout/ExtraSpacing,Layout/ArrayAlignment

  # Symbol values in order by encoded ASCII ordinal values.
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

  # Encoding symbols ordered by bit value.
  ENCODE_SYMBOLS = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F",
    "G", "H", "J", "K", "M", "N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z",
    "*", "~", "$", "=", "U"
  ].freeze

  # standard:enable Layout/ExtraSpacing,Layout/ArrayAlignment

  # @!group Public Methods

  # Decode a Base32 value.
  #
  # @since 1.0.0
  #
  # @param value [String] the Base32 value to decode.
  # @param into [Symbol] the destination type to decode into. Can be +:integer+ or +:string+.
  # @param check [Boolean] whether to validate the check symbol.
  # @param length [Integer, nil] the length of the resulting string when right padded.
  #
  # @return [Integer, String] the decoded value.
  #
  # @raise [ChecksumError] when the check symbol does not match the decoded checksum.
  # @raise [InvalidCharacterError] when the value being decoded has a character outside the
  #   Base32 symbol set or a misplaced check symbol.
  # @raise [UnsupportedDecodingTypeError] when the requested +into:+ type is not supported.
  def self.decode(value, into: :integer, check: false, length: nil)
    checksum = check ? value[-1] : nil
    value = check ? value[0...-1] : value

    result = le_decode_number value

    if check
      actual = result % CHECKSUM_PRIME
      required = DECODE_ORDINALS[checksum.ord]
      raise ChecksumError.new(value, actual, required) if actual != required
    end

    convert result, into, length
  end

  # Encode a value as Base32.
  #
  # @since 1.0.0
  #
  # @param value [Integer, String] the value to encode.
  # @param length [Integer] the exact length of the Base32 string. Will be padded with "0" to meet length.
  # @param check [Boolean] whether to include a check symbol. This symbol is included in the length.
  #
  # @return [String] the encoded value.
  #
  # @raise [LengthTooSmallError] when the requested +length:+ is not large enough to fit the encoded result.
  # @raise [UnsupportedEncodingTypeError] when the value to encode is an unsupported type.
  def self.encode(value, length: nil, check: false)
    le_encode_number(raw_value_to_number(value), length, check)
  end

  # @!endgroup

  # @!group Private Methods
  # @!visibility private

  # Decode a value with the expectation that it is in little-endian order.
  #
  # @param encoded_value [String] the value to decode.
  # @return [Integer] the decoded value.
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

  # Convert a decoded result into the destination type.
  #
  # @param result [Integer] the decoded value.
  # @param type [Symbol] the destination type for the value. Can be +:integer+ or +:string+.
  # @param length [Integer, nil] the length to pad the string to.
  # @return [Integer, String] the decoded value converted to the destination type.
  def self.convert(result, type, length)
    case type
    when :integer
      result
    when :string
      into_string result, length
    else
      raise UnsupportedDecodingTypeError.new(type)
    end
  end

  # Convert an Integer into a String.
  #
  # Each 8-bit sequence is packed into a String in little-endian order.
  #
  # @param result [Integer] the decoded value.
  # @param length [Integer, nil] the length of the decoded value with right padding.
  # @return [String] the decoded value as a String.
  def self.into_string(result, length)
    q, r = result.bit_length.divmod(0x08)
    q += 1 if r > 0
    bytes = Array.new(q)
    q.times do |i|
      bytes[i] = result & 0xff
      result >>= 0x08
    end

    bstr = bytes.pack("C*")
    return bstr if length.nil?

    bstr.ljust(length, "\x00")
  end

  # Convert a raw value into an Integer for encoding.
  #
  # @param value [Integer, String] the value being encoded.
  # @return [Integer] the value converte to an Integer.
  def self.raw_value_to_number(value)
    case value
    when String
      q, r = value.bytesize.divmod(8)
      if r == 0
        string_to_integer_unrolled value, q
      else
        string_to_integer value
      end
    when Integer
      value
    else
      raise UnsupportedEncodingTypeError.new value.class
    end
  end

  # Convert a String to an Integer one byte per iteration.
  #
  # @param s [String] the String to convert.
  # @return [Integer] the String converted to an Integer in little-endian order.
  def self.string_to_integer(s)
    shift = -0x08
    s.each_byte.reduce(0) do |n, b|
      shift += 0x08
      n + (b << shift)
    end
  end

  # Convert a String to an Integer 8 bytes per iteration.
  # @param s [String] the String to convert.
  # @param iterations [Integer] the number of iterations to perform.
  # @return [Integer] the String converted to an Integer in little-endian order.
  def self.string_to_integer_unrolled(s, iterations)
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

  # Encode an Integer as a Base32 value.
  #
  # @see encode
  # @return [String]
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

  private_class_method :le_decode_number, :convert, :into_string, :raw_value_to_number,
    :string_to_integer, :string_to_integer_unrolled, :le_encode_number

  # @!endgroup
end
