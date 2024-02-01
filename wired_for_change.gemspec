# frozen_string_literal: true

require_relative "lib/wired_for_change/version"

Gem::Specification.new do |spec|
  spec.name = "wired_for_change"
  spec.version = WiredForChange::VERSION
  spec.authors = ["ActBlue Technical Services"]
  spec.email = ["support@actblue.com"]
  spec.summary = "Track donors through Salsa Labs"
  spec.description = "Track donors through Salsa Labs using this Gem"
  spec.homepage = "https://github.com/actblue/wired_for_change"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.0.0"
  spec.metadata[
    "source_code_uri"
  ] = "https://github.com/actblue/wired_for_change"

  spec.files =
    `git ls-files -z`.split("\x0")
      .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rexml", "~> 3.2"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha", "~> 2.0"
end
