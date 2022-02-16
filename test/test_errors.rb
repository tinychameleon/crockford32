# frozen_string_literal: true

require "test_helper"

class TestCrockford32Errors < Minitest::Test
  def test_base_decode_error
    err = ::Crockford32::DecodeError.new("message", "AUBC", 1)
    assert_equal "AUBC", err.string, "string = AUBC"
    assert_equal 1, err.index, "index = 1"
    assert_equal "message", err.message, "friendly message"
  end

  def test_invalid_character_error
    err = ::Crockford32::InvalidCharacterError.new("AUBC", 1)
    assert_kind_of ::Crockford32::DecodeError, err
    assert_equal "Invalid character 'U' in 'AUBC' at index 1", err.message, "friendly message"
  end

  def test_illegal_checksum_character_error
    err = ::Crockford32::IllegalChecksumCharacterError.new("AUBC", 1)
    assert_kind_of ::Crockford32::DecodeError, err
    assert_equal "Checksum character 'U' in 'AUBC' at index 1 instead of at end", err.message, "friendly message"
  end
end
