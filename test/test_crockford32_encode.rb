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
    assert_equal "J61", ::Crockford32.encode(1234), "encode(1234)"
    assert_equal "SVQV0329G3", ::Crockford32.encode(123456789012345), "encode(123456789012345)"
    assert_equal "0000HHN5YTHQP2", ::Crockford32.encode(1e20.to_i), "encode(1e20)"
  end

  def test_encode_can_insert_dashes_at_steps
    assert_equal "SVQ-V03-29G-3", ::Crockford32.encode(123456789012345, step: 3), "encode(123456789012345, step: 3)"
  end

  def test_encode_can_pad_to_a_length
    assert_equal "J6100", ::Crockford32.encode(1234, length: 5), "encode(1234, length: 5)"
  end

  def test_encode_can_pad_and_insert_dashes
    assert_equal "J6-10", ::Crockford32.encode(1234, length: 5, step: 2), "encode(1234, length: 5, step: 2)"
  end

  def test_encode_with_a_length_smaller_than_the_result_is_an_error
    assert_raises(::Crockford32::LengthTooSmallError) { ::Crockford32.encode(1234, length: 1) }
  end

  def test_encode_with_an_unsupported_type_is_an_error
    assert_raises(::Crockford32::UnsupportedEncodingTypeError) { ::Crockford32.encode(/abc/) }
  end

  def test_encode_can_include_checksum
    assert_equal "J61D", ::Crockford32.encode(1234, check: true), "encode(1234, check: true)"
    assert_equal "N8KQN3U", ::Crockford32.encode(123456789, check: true), "encode(123456789, check: true)"
    assert_equal "0000HHN5YTHQP2T", ::Crockford32.encode(1e20.to_i, check: true), "encode(1e20, check: true)"
  end

  def test_encode_can_pad_and_insert_dashes_and_include_a_checksum
    assert_equal "J6-10-00D", ::Crockford32.encode(1234, step: 2, length: 9, check: true)
    assert_equal "J6-10-0D", ::Crockford32.encode(1234, step: 2, length: 8, check: true)
    assert_equal "J6-10-D", ::Crockford32.encode(1234, step: 2, length: 7, check: true)
    assert_equal "J6-10D", ::Crockford32.encode(1234, step: 2, length: 6, check: true)
    assert_equal "J6-1D", ::Crockford32.encode(1234, step: 2, length: 5, check: true)
  end
end
