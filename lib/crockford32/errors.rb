# frozen_string_literal: true

module Crockford32
  # The base error for all possible errors from {Crockford32}
  class Error < StandardError; end

  # The base error for all errors from {Crockford32.encode}
  class EncodeError < Error; end

  # The base error for all errors from {Crockford32.decode}
  class DecodeError < Error; end

  # An error representing the length of an encoded value being larger than the
  # requested maximum length.
  class LengthTooSmallError < EncodeError
    # @param value [Integer, String] the value to be encoded.
    # @param needed [Integer] the needed length to encode the value.
    # @param given [Integer] the specified length to encode the value.
    def initialize(value, needed, given)
      super("Encoding #{value} requires a minimum length of #{needed}, but received #{given}")
    end
  end

  # An error representing an attmept to encode an unsupported type.
  class UnsupportedEncodingTypeError < EncodeError
    # @param type [Type] the unsupported type of the encode attempt.
    def initialize(type)
      super("Encoding #{type} not supported")
    end
  end

  # An error representing a decode operation finding an illegal symbol within a
  # provided value.
  class InvalidCharacterError < DecodeError
    # @param string [String] the string to decode.
    # @param index [Integer] the index within the string of the invalid character.
    def initialize(string, index)
      super("Invalid character '#{string[index]}' in '#{string}' at index #{index}")
    end
  end

  # An error representing an unsupported destination type for a decode operation.
  class UnsupportedDecodingTypeError < DecodeError
    # @param type [Symbol] the supplied destination type.
    def initialize(type)
      super("Decoding as :#{type} not supported")
    end
  end

  # An error representing a checksum mismatch between the decoded value and the
  # supplied check symbol.
  class ChecksumError < DecodeError
    # @param value [String] the Base32 value to decode.
    # @param checksum [Integer] the checksum of the decoded value.
    # @param checksum_required [Integer] the required checksum of the decoded value.
    def initialize(value, checksum, checksum_required)
      super("Value #{value} has checksum #{checksum} but requires #{checksum_required}")
    end
  end
end
