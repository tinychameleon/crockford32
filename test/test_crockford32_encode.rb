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
    assert_equal "2PQHTY5NHH0000", ::Crockford32.encode(1e20), "encode(1e20)"
  end
end
