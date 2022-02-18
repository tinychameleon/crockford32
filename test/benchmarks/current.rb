# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "benchmark/ips"
require "crockford32"

Benchmark.ips do |b|
  int = 281215901112853698913811278589568185362
  data = "RDAY06P4HGXEF1JW5KTB3VC2ZM"
  bytes = "\xCAktX\xDF\xDA\x80o\t\x96\x94\xE0\x98\xFC\xA8\xDD"

  b.report("encode") do |n|
    n.times { Crockford32.encode(int) }
  end

  b.report("decode") do |n|
    n.times { Crockford32.decode(data) }
  end

  b.report("encode string") do |n|
    n.times { Crockford32.encode(bytes) }
  end

  b.report("decode string") do |n|
    n.times { Crockford32.decode(data, into: :string) }
  end
end
