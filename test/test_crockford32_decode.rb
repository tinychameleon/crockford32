# frozen_string_literal: true

require "test_helper"

class TestCrockford32Decode < Minitest::Test
  VALUES = {
    0 => { decode: ['0', 'O', 'o'], encode: '0' },
    1 => { decode: ['1', 'I', 'i', 'L', 'l'], encode: '1' },
    2 => { decode: ['2'], encode: '2' },
    3 => { decode: ['3'], encode: '3' },
    4 => { decode: ['4'], encode: '4' },
    5 => { decode: ['5'], encode: '5' },
    6 => { decode: ['6'], encode: '6' },
    7 => { decode: ['7'], encode: '7' },
    8 => { decode: ['8'], encode: '8' },
    9 => { decode: ['9'], encode: '9' },
    10 => { decode: ['A', 'a'], encode: 'A' },
    11 => { decode: ['B', 'b'], encode: 'B' },
    12 => { decode: ['C', 'c'], encode: 'C' },
    13 => { decode: ['D', 'd'], encode: 'D' },
    14 => { decode: ['E', 'e'], encode: 'E' },
    15 => { decode: ['F', 'f'], encode: 'F' },
    16 => { decode: ['G', 'g'], encode: 'G' },
    17 => { decode: ['H', 'h'], encode: 'H' },
    18 => { decode: ['J', 'j'], encode: 'J' },
    19 => { decode: ['K', 'k'], encode: 'K' },
    20 => { decode: ['M', 'm'], encode: 'M' },
    21 => { decode: ['N', 'n'], encode: 'N' },
    22 => { decode: ['P', 'p'], encode: 'P' },
    23 => { decode: ['Q', 'q'], encode: 'Q' },
    24 => { decode: ['R', 'r'], encode: 'R' },
    25 => { decode: ['S', 's'], encode: 'S' },
    26 => { decode: ['T', 't'], encode: 'T' },
    27 => { decode: ['V', 'v'], encode: 'V' },
    28 => { decode: ['W', 'w'], encode: 'W' },
    29 => { decode: ['X', 'x'], encode: 'X' },
    30 => { decode: ['Y', 'y'], encode: 'Y' },
    31 => { decode: ['Z', 'z'], encode: 'Z' },
  }.freeze

  CHECKS = {
    32 => { decode: ['*'], encode: '*' },
    33 => { decode: ['~'], encode: '~' },
    34 => { decode: ['$'], encode: '$' },
    35 => { decode: ['='], encode: '=' },
    36 => { decode: ['U', 'u'], encode: 'U' },
  }.freeze

  def test_individual_characters_decode_correctly
    VALUES.each do |val, config|
      config[:decode].each do |ch|
        assert_equal val, ::Crockford32.decode(ch), "decode('#{ch}')"
      end
    end
  end

  def test_simple_encodings_decode_correctly
    assert_equal 1234, ::Crockford32.decode("16J"), "decode('16J')"
    assert_equal 123456789012345, ::Crockford32.decode("3G9230VQVS"), "decode('3G9230VQVS')"
    assert_equal 1e20.to_i, ::Crockford32.decode("2pqhty5nhhoooo"), "decode('2pqhty5nhhoooo')"
  end

  def test_confusing_symbols_decode_correctly
    assert_equal 33587232, ::Crockford32.decode("101o1O"), "decode('101o1O')"
    assert_equal 33825, ::Crockford32.decode("IiLl"), "decode('IiLl')"
  end

  def test_decode_supports_arbitrary_dashes
    assert_equal 1234, ::Crockford32.decode("16-J"), "decode('16-J')"
    assert_equal 123456789012345, ::Crockford32.decode("3G-923-0VQ-VS"), "decode('3G-923-0VQ-VS')"
    assert_equal 1e20.to_i, ::Crockford32.decode("2pqhty5-nhhoooo"), "decode('2pqhty5-nhhoooo')"
  end

  def test_checksum_symbols_mid_string_is_an_error
    assert_raises(::Crockford32::IllegalChecksumCharacterError) { ::Crockford32.decode('ABC*123') }
  end

  def test_unicode_symbols_mid_string_is_an_error
    assert_raises(::Crockford32::InvalidCharacterError) { ::Crockford32.decode('ABCé123') }
  end

  def test_unsupported_decode_type_is_an_error
    assert_raises(::Crockford32::UnsupportedDecodingTypeError) { ::Crockford32.decode("16J", as: :apple) }
  end
end
