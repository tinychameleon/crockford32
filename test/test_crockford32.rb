# frozen_string_literal: true

require "test_helper"

class TestCrockford32 < Minitest::Test
  def test_it_has_a_version_number
    refute_nil ::Crockford32::VERSION
  end

  # TODO:
  # - Encoding values
  #   - Left extension for encoding values in multiples of 5 bits.
  # - Support binary values for encoding
  # - Benchmark + optimize
end
