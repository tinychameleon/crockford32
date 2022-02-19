# frozen_string_literal: true

require "test_helper"

class TestCrockford32Decode < Minitest::Test
  def test_individual_characters_decode_correctly
    {
      0 => ["0", "O", "o"], 1 => ["1", "I", "i", "L", "l"], 2 => ["2"], 3 => ["3"],
      4 => ["4"], 5 => ["5"], 6 => ["6"], 7 => ["7"], 8 => ["8"], 9 => ["9"],
      10 => ["A", "a"], 11 => ["B", "b"], 12 => ["C", "c"], 13 => ["D", "d"],
      14 => ["E", "e"], 15 => ["F", "f"], 16 => ["G", "g"], 17 => ["H", "h"],
      18 => ["J", "j"], 19 => ["K", "k"], 20 => ["M", "m"], 21 => ["N", "n"],
      22 => ["P", "p"], 23 => ["Q", "q"], 24 => ["R", "r"], 25 => ["S", "s"],
      26 => ["T", "t"], 27 => ["V", "v"], 28 => ["W", "w"], 29 => ["X", "x"],
      30 => ["Y", "y"], 31 => ["Z", "z"]
    }.each do |val, symbols|
      symbols.each { |ch| assert_equal val, ::Crockford32.decode(ch), "decode('#{ch}')" }
    end
  end

  def test_simple_encodings_decode_correctly
    assert_equal 1234, ::Crockford32.decode("J61")
    assert_equal 123456789012345, ::Crockford32.decode("SVQV0329G3")
    assert_equal 1e20.to_i, ::Crockford32.decode("0000hhn5ythqp2")
  end

  def test_confusing_symbols_decode_correctly
    assert_equal 33587232, ::Crockford32.decode("O1o101")
    assert_equal 33825, ::Crockford32.decode("lLiI")
  end

  def test_decode_supports_arbitrary_dashes
    assert_equal 1234, ::Crockford32.decode("J-61")
    assert_equal 123456789012345, ::Crockford32.decode("SV-QV0-32-9G3")
    assert_equal 1e20.to_i, ::Crockford32.decode("0000hhn-5ythqp2")
  end

  def test_checksum_symbols_mid_string_is_an_error
    assert_raises(::Crockford32::InvalidCharacterError) { ::Crockford32.decode("ABC*123") }
  end

  def test_unicode_symbols_mid_string_is_an_error
    assert_raises(::Crockford32::InvalidCharacterError) { ::Crockford32.decode("ABCé123") }
  end

  def test_unsupported_decode_type_is_an_error
    assert_raises(::Crockford32::UnsupportedDecodingTypeError) { ::Crockford32.decode("J61", into: :apple) }
  end

  def test_default_decode_type_is_integer
    assert_equal ::Crockford32.decode("J61"), ::Crockford32.decode("J61", into: :integer)
  end

  def test_decode_supports_checksum_verification
    assert_equal 1234, ::Crockford32.decode("J61D", check: true)
    assert_equal 123456789, ::Crockford32.decode("N8KQN3u", check: true)
    assert_equal 1e20.to_i, ::Crockford32.decode("0000hhn5ythqp2T", check: true)
    assert_equal 1234, ::Crockford32.decode("J6-10-0D", check: true)
  end

  def test_checksum_mismatch_is_an_error
    assert_raises(::Crockford32::ChecksumError) { ::Crockford32.decode("J71D", check: true) }
  end
end
