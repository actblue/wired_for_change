# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wired_for_change/version'

Gem::Specification.new do |spec|
  spec.name          = "wired_for_change"
  spec.version       = WiredForChange::VERSION
  spec.authors       = ["ActBlue Technical Services"]
  spec.email         = ["contact@actblue.com"]
  spec.summary       = "Track donors through Salsa Labs"
  spec.description   = "Track donors through Salsa Labs using this Gem"
  spec.homepage      = "https://github.com/actblue/wired_for_change"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
