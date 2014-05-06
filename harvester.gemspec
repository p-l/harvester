# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'harvester/version'

Gem::Specification.new do |spec|
  spec.name          = "harvester"
  spec.version       = Harvester::VERSION
  spec.authors       = ["Pierre-Luc Simard"]
  spec.email         = ["pls@6x9.ca"]
  spec.summary       = %q{Library and command line utility to interact with Harvest Time Tracking}
  spec.description   = %q{}
  spec.homepage      = "http://github.com/p-l/harvester"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'harvested', "~> 2.0.0"
  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
