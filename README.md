# Crockford32

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/crockford32`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crockford32'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install crockford32

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Benchmarks
These benchmarks are representative of performance on a constant 16 bytes of data given the following environment:

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

```
~/…/crockford32› date && ruby test/benchmarks/current.rb
Fri Feb 18 11:29:28 PST 2022
Warming up --------------------------------------
              encode    11.234k i/100ms
              decode    11.369k i/100ms
       encode string     8.012k i/100ms
       decode string     7.097k i/100ms
Calculating -------------------------------------
              encode    116.742k (± 3.4%) i/s -    584.168k in   5.009868s
              decode    114.187k (± 2.9%) i/s -    579.819k in   5.082251s
       encode string     79.347k (± 3.4%) i/s -    400.600k in   5.054837s
       decode string     71.833k (± 2.7%) i/s -    361.947k in   5.042572s
```
