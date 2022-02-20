# frozen_string_literal: true

require_relative "lib/crockford32/version"

Gem::Specification.new do |spec|
  spec.name = "crockford32"
  spec.version = Crockford32::VERSION
  spec.license = "MIT"
  spec.authors = ["Stephan Tarulli"]
  spec.email = ["srt@tinychameleon.com"]

  spec.summary = "A fast little-endian implementation of Crockford's Base32 specification."
  spec.description = "A fast little-endian implementation of Crockford's Base32 specification."
  spec.homepage = "https://github.com/tinychameleon/crockford32"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = File.join(spec.homepage, "blob/main/CHANGELOG.md")
  spec.metadata["bug_tracker_uri"] = File.join(spec.homepage, "issues")
  spec.metadata["documentation_uri"] = "https://tinychameleon.github.io/crockford32/"

  spec.files = Dir["README.md", "CHANGELOG.md", "LICENSE", "lib/**/*.rb"]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
