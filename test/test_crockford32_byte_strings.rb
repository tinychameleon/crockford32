# encoding: ascii-8bit
# frozen_string_literal: true

require "test_helper"

class TestCrockford32DecodeAscii < Minitest::Test
  def test_decode_supports_byte_strings
    assert_equal "\xd2\x04", ::Crockford32.decode("J61", into: :string), "decode('16J', into: :string)"
    assert_equal "\x79\xdf\x0d\x86\x48\x70", ::Crockford32.decode("SVQV0329G3", into: :string), "decode('3G9230VQVS', into: :string)"
    assert_equal "\x00\x00\x10\x63\x2d\x5e\xc7\x6b\x05", ::Crockford32.decode("0000hhn5ythqp2", into: :string), "decode('2PQHTY5NHH0000', into: :string)"
  end

  def test_encode_supports_byte_strings
    assert_equal "J61", ::Crockford32.encode("\xd2\x04"), "encode('\\x04\\xd2')"
    assert_equal "SVQV0329G3", ::Crockford32.encode("\x79\xdf\x0d\x86\x48\x70"), "encode('\\x70\\x48\\x86\\x0d\\xdf\\x79')"
    assert_equal "0000HHN5YTHQP2", ::Crockford32.encode("\x00\x00\x10\x63\x2d\x5e\xc7\x6b\x05"), "encode('\\x05\\x6b\\xc7\\x5e\\x2d\\x63\\x10\\x00\\x00')"
  end

  def test_encode_works_with_factor_8_loop_unrolling
    s = "\xff\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
    assert_equal "ZF04G1G05G1E0441AR2RG6R1F", ::Crockford32.encode(s)
  end

  def test_round_trips_are_reciprocal
    assert_equal 1234, ::Crockford32.decode(::Crockford32.encode(1234))
    assert_equal "\x04\xd2", ::Crockford32.decode(::Crockford32.encode("\x04\xd2"), into: :string)
  end
end
