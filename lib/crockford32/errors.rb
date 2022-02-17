# frozen_string_literal: true

module Crockford32
  class Error < StandardError; end

  class EncodeError < Error; end
  class DecodeError < Error; end

  class LengthTooSmallError < EncodeError
    def initialize(value, needed, given)
      super("Encoding #{value} requires a minimum length of #{needed}, but received #{given}")
    end
  end

  class UnsupportedEncodingTypeError < EncodeError
    def initialize(type)
      super("Encoding #{type} not supported")
    end
  end

  class InvalidCharacterError < DecodeError
    def initialize(string, index)
      super("Invalid character '#{string[index]}' in '#{string}' at index #{index}")
    end
  end

  class UnsupportedDecodingTypeError < DecodeError
    def initialize(type)
      super("Decoding as :#{type} not supported")
    end
  end

  class ChecksumError < DecodeError
    def initialize(value, checksum, checksum_required)
      super("Value #{value} has checksum #{checksum} but requires #{checksum_required}")
    end
  end
end
