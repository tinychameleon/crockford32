# frozen_string_literal: true

require "test_helper"

class TestCrockford32Encode < Minitest::Test
  VALUES = {
    0 => '0',
    1 => '1',
    2 => '2',
    3 => '3',
    4 => '4',
    5 => '5',
    6 => '6',
    7 => '7',
    8 => '8',
    9 => '9',
    10 => 'A',
    11 => 'B',
    12 => 'C',
    13 => 'D',
    14 => 'E',
    15 => 'F',
    16 => 'G',
    17 => 'H',
    18 => 'J',
    19 => 'K',
    20 => 'M',
    21 => 'N',
    22 => 'P',
    23 => 'Q',
    24 => 'R',
    25 => 'S',
    26 => 'T',
    27 => 'V',
    28 => 'W',
    29 => 'X',
    30 => 'Y',
    31 => 'Z',
  }.freeze

  CHECKS = {
    32 => { decode: ['*'], encode: '*' },
    33 => { decode: ['~'], encode: '~' },
    34 => { decode: ['$'], encode: '$' },
    35 => { decode: ['='], encode: '=' },
    36 => { decode: ['U', 'u'], encode: 'U' },
  }.freeze

  def test_individual_numbers_encode_correctly
    VALUES.each do |val, result|
      assert_equal result, ::Crockford32.encode(val), "encode('#{val}')"
    end
  end

  def test_simple_values_encode_correctly
    assert_equal "16J", ::Crockford32.encode(1234), "encode(1234)"
    assert_equal "3G9230VQVS", ::Crockford32.encode(123456789012345), "encode(123456789012345)"
    assert_equal "2PQHTY5NHH0000", ::Crockford32.encode(1e20.to_i), "encode(1e20)"
  end

  def test_encode_can_insert_dashes_at_steps
    assert_equal "3-G92-30V-QVS", ::Crockford32.encode(123456789012345, step: 3), "encode(123456789012345, step: 3)"
  end

  def test_encode_can_pad_to_a_length
    assert_equal "0016J", ::Crockford32.encode(1234, length: 5), "encode(1234, length: 5)"
  end

  def test_encode_can_pad_and_insert_dashes
    assert_equal "01-6J", ::Crockford32.encode(1234, length: 5, step: 2), "encode(1234, length: 5, step: 2)"
  end

  def test_encode_with_a_length_smaller_than_the_result_is_an_error
    assert_raises(::Crockford32::LengthTooSmallError) { ::Crockford32.encode(1234, length: 1) }
  end

  def test_encode_supports_byte_strings
    assert_equal "16J", ::Crockford32.encode("\x04\xd2"), "encode('\\x04\\xd2')"
    assert_equal "3G9230VQVS", ::Crockford32.encode("\x70\x48\x86\x0d\xdf\x79"), "encode('\\x70\\x48\\x86\\x0d\\xdf\\x79')"
    assert_equal "2PQHTY5NHH0000", ::Crockford32.encode("\x05\x6b\xc7\x5e\x2d\x63\x10\x00\x00"), "encode('\\x05\\x6b\\xc7\\x5e\\x2d\\x63\\x10\\x00\\x00')"
  end

  def test_encode_with_an_unsupported_type_is_an_error
    assert_raises(::Crockford32::UnsupportedTypeError) { ::Crockford32.encode(/abc/) }
  end
end
