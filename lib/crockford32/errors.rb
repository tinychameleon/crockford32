# frozen_string_literal: true

module Crockford32
  class Error < StandardError; end

  class EncodeError < Error; end

  class LengthTooSmallError < EncodeError
    def initialize(value, needed, given)
      super("Encoding #{value} requires a minimum length of #{needed}, but received #{given}")
    end
  end

  class UnsupportedTypeError < EncodeError
    def initialize(type)
      super("Encoding #{type} not supported")
    end
  end

  class DecodeError < Error
    attr_reader :string, :index

    def initialize(message, string, index)
      super(message)
      @string = string
      @index = index
    end
  end

  class InvalidCharacterError < DecodeError
    def initialize(string, index)
      msg = "Invalid character '#{string[index]}' in '#{string}' at index #{index}"
      super(msg, string, index)
    end
  end

  class IllegalChecksumCharacterError < DecodeError
    def initialize(string, index)
      msg = "Checksum character '#{string[index]}' in '#{string}' at index #{index} instead of at end"
      super(msg, string, index)
    end
  end
end
