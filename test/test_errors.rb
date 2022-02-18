# frozen_string_literal: true

require "test_helper"

class TestCrockford32Errors < Minitest::Test
  def test_length_too_small_error
    err = ::Crockford32::LengthTooSmallError.new("ABC", 6, 4)
    assert_kind_of ::Crockford32::EncodeError, err
    assert_equal "Encoding ABC requires a minimum length of 6, but received 4", err.message
  end

  def test_unsupported_encoding_type_error
    err = ::Crockford32::UnsupportedEncodingTypeError.new(Regexp)
    assert_kind_of ::Crockford32::EncodeError, err
    assert_equal "Encoding Regexp not supported", err.message
  end

  def test_invalid_character_error
    err = ::Crockford32::InvalidCharacterError.new("AUBC", 1)
    assert_kind_of ::Crockford32::DecodeError, err
    assert_equal "Invalid character 'U' in 'AUBC' at index 1", err.message
  end

  def test_invalid_target_type_error
    err = ::Crockford32::UnsupportedDecodingTypeError.new(:apple)
    assert_kind_of ::Crockford32::DecodeError, err
    assert_equal "Decoding as :apple not supported", err.message
  end

  def test_checksum_error
    err = ::Crockford32::ChecksumError.new("ABC", 1, 2)
    assert_kind_of ::Crockford32::DecodeError, err
    assert_equal "Value ABC has checksum 1 but requires 2", err.message
  end
end
