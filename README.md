# Crockford32
A fast little-endian implementation of [Douglas Crockford's Base32 specification](https://www.crockford.com/base32.html).

[![Gem Version](https://badge.fury.io/rb/crockford32.svg)](https://badge.fury.io/rb/crockford32)

## What's in the box?
✅ Simple usage documentation written to get started fast. [Check it out!](#usage)

⚡ A pretty fast implementation of Crockford32 in pure ruby. [Check it out!](#benchmarks)

📚 YARD generated API documentation for the library. [Check it out!](https://tinychameleon.github.io/crockford32/)

🤖 RBS types for your type checking wants. [Check it out!](./sig/crockford32.rbs)

💎 Tests against many Ruby versions. [Check it out!](#ruby-versions)

🔒 MFA protection on all gem owners. [Check it out!](https://rubygems.org/gems/crockford32)


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'crockford32'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install crockford32

### Ruby Versions
This gem is tested against the following Ruby versions:

- 2.6.0
- 2.6.9
- 2.7.0
- 2.7.5
- 3.0.0
- 3.0.3
- 3.1.0
- 3.1.1


## Usage
Encode data with the `encode` method:

```ruby
encoded = Crockford32.encode(1234) # encoded = "J61"
```
See the [the encode API documentation for error details](https://tinychameleon.github.io/crockford32/Crockford32.html#encode-class_method).

---

Decode a value with the `decode` method:

```ruby
decoded = Crockford32.decode("J61") # decoded = 1234
```
See the [the decode API documentation for error details](https://tinychameleon.github.io/crockford32/Crockford32.html#decode-class_method).


### Strings
You can also encode and decode strings by providing the `:string` value as the `into:` argument to `decode`.
Encoding a string requires no special consideration.

```ruby
encoded = Crockford32.encode("abc") # encoded = "1KR66"
decoded = Crockford32.decode(encoded, into: :string) # decoded = "abc"
```

When decoding you may receive a byte string if the encoded value is not alphanumeric:

```ruby
decoded = Crockford32.decode("J61", into: :string) # decoded = "\xD2\x04"
```

### Padding to a Length
You can ensure your encoded values are a specific length by specifying a `length:` on `encode`:

```ruby
encoded = Crockford32.encode(1234, length: 5) # encoded = "J6100"
```

The padding is always "0" values and is always appended to the end of the encoded string.
Whatever you specify as the `length:` will be the length of the encoded string you receive.

Decoding also supports a `length:` argument for symmetry when using `into: :string`:

```ruby
decoded = Crockford32.decode("J61", length: 5, into: :string) # decoded = "\xD2\x04\x00\x00\x00"
```

Any length given to `Crockford32.decode` will not truncate valid decoding results. The `length:`
is treated as a minimum.

### Check Symbols
If you wish to append a check symbol for simple modulus-based error detection both `encode` and `decode` support it with the `check:` keyword.

```ruby
encoded = Crockford32.encode(1234, check: true) # encoded = "J61D". "D" is the checksum symbol.
decoded = Crockford32.decode(encoded, check: true) # decoded = 1234. Checksum is tested.
```

An error will be raised if the decoding process does not pass the checksum:

```ruby
decoded = Crockford32.decode("J71D", check: true) # Notice the 6 changed to a 7.
~/.../crockford32/lib/crockford32.rb:43:in `decode': Value J71 has checksum 8 but requires 13 (Crockford32::ChecksumError)
	from (irb):2:in `<main>'
	from bin/console:8:in `<main>'
```

If you specify a `length:` and `check: true` when encoding, the checksum will be included as part of the `length:`.

### Encoding Type Support
This library currently supports encoding `Integer` and `String` values.

### Little-Endian Encoding
The encoding example above shows the little-endian results of encoding a number.
Some libraries encode using big-endian and will return `"16J"` when the number `1234` is encoded.

This library _always_ uses little-endian.

### More Information
For more detailed information about the library [see the API documentation](https://tinychameleon.github.io/crockford32/).


## Contributing

### Development
To get started development on this gem run the `bin/setup` command. This will install dependencies and run the tests and linting tasks to ensure everything is working.

For an interactive console with the gem loaded run `bin/console`.


### Testing
Use the `bundle exec rake test` command to run unit tests. To install the gem onto your local machine for general integration testing use `bundle exec rake install`.

To test the gem against each supported version of Ruby use `bin/test_versions`. This will create a Docker image for each version and run the tests and linting steps.


### Releasing
Do the following to release a new version of this gem:

- Update the version number in [lib/crockford32/version.rb](./lib/crockford32/version.rb)
- Ensure necessary documentation changes are complete
- Ensure changes are in the [CHANGELOG.md](./CHANGELOG.md)
- Create the new release using `bundle exec rake release`

After this is done the following side-effects should be visible:

- A new git tag for the version number should exist
- Commits for the new version should be pushed to GitHub
- The new gem should be available on [rubygems.org](https://rubygems.org).

Finally, update the documentation hosted on GitHub Pages:

- Check-out the `gh-pages` branch
- Merge `main` into the `gh-pages` branch
- Generate the documentation with `bundle exec rake yard`
- Commit the documentation on the `gh-pages` branch
- Push the new documentation so GitHub Pages can deploy it


## Benchmarks
Benchmarking is tricky and the goal of a benchmark should be clear before attempting performance improvements. The goal of this library for performance is as follows:

> This library should be capable of encoding and decoding IDs at a rate which does not make it a bottleneck for the majority of web APIs.

Given the above goal statement, these benchmarks run on the following environment:

| Attribute | Value |
|:--|--:|
| Ruby Version | 3.1.0 |
| MacOS Version | Catalina 10.15.7 (19H1615) |
| MacOS Model Identifier | MacBookPro10,1 |
| MacOS Processor Name | Quad-Core Intel Core i7 |
| MacOS Processor Speed | 2.7 GHz |
| MacOS Number of Processors | 1 |
| MacOS Total Number of Cores | 4 |
| MacOS L2 Cache (per Core) | 256 KB |
| MacOS L3 Cache | 6 MB |
| MacOS Hyper-Threading Technology | Enabled |
| MacOS Memory | 16 GB |

When run using a constant 16 bytes of data in the above environment the performance is approximately as follows:

```
~/…/crockford32› date && ruby test/benchmarks/current.rb
Fri Feb 18 15:35:49 PST 2022
Warming up --------------------------------------
              encode    11.498k i/100ms
              decode    10.550k i/100ms
       encode string     7.686k i/100ms
       decode string     6.798k i/100ms
Calculating -------------------------------------
              encode    117.614k (± 3.5%) i/s -    597.896k in   5.090119s
              decode    108.253k (± 3.2%) i/s -    548.600k in   5.073326s
       encode string     78.690k (± 3.1%) i/s -    399.672k in   5.084255s
       decode string     69.707k (± 3.5%) i/s -    353.496k in   5.077700s
```

Being conservative in estimation 30k i/s round trip decoding and encoding cycles should be possible. This achieves the performance goal.
