# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lifft/version'

Gem::Specification.new do |spec|
  spec.name          = "lifft"
  spec.version       = Lifft::VERSION
  spec.authors       = ["Benjamin Briggs"]
  spec.email         = ["ben@palringo.com"]
  spec.summary       = "Xcode -> Xliffs -> GetLocalization"
  spec.description   = "A simple tool for extracting & uploading Xliffs to GetLocalization"
  spec.homepage      = "https://github.com/BenjaminBriggs/lifft"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "thor", '~> 0.19'
  spec.add_dependency "json", '~> 1.8'
  spec.add_dependency "httmultiparty", '~> 0.3'
  spec.add_dependency "iso-639", '~>0.2'

end
