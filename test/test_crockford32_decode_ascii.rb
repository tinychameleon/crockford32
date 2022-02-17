# encoding: ascii-8bit
# frozen_string_literal: true

require "test_helper"

class TestCrockford32DecodeAscii < Minitest::Test
  def test_decode_supports_byte_strings
    assert_equal "\x04\xd2", ::Crockford32.decode("16J", as: :string), "decode('16J', as: :string)"
    assert_equal "\x70\x48\x86\x0d\xdf\x79", ::Crockford32.decode("3G9230VQVS", as: :string), "decode('3G9230VQVS', as: :string)"
    assert_equal "\x05\x6b\xc7\x5e\x2d\x63\x10\x00\x00", ::Crockford32.decode("2PQHTY5NHH0000", as: :string), "decode('2PQHTY5NHH0000', as: :string)"
  end
end
