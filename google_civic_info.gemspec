# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_civic_info/version'

Gem::Specification.new do |spec|
  spec.name          = "google_civic_info"
  spec.version       = GoogleCivicInfo::VERSION
  spec.authors       = ["Benjamin Stein"]
  spec.email         = ["ben@mobilecommons.com"]
  spec.description   = %q{Ruby client for Google Civic Info API}
  spec.summary       = %q{Ruby client for Google Civic Info API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
