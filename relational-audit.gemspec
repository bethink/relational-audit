# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relational/audit/version'

Gem::Specification.new do |spec|
  spec.name          = "relational-audit"
  spec.version       = Relational::Audit::VERSION
  spec.authors       = ["Manojs"]
  spec.email         = ["manojs.nitt@gmail.com"]
  spec.summary       = %q{Audit for entities not for table. Entity consists of information from multiple related tables}
  spec.description   = %q{Audit for entities not for table. Entity consists of information from multiple related tables}
  spec.homepage      = "https://github.com/bethink/relational-audit"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'activerecord', ['>= 3.0', '< 5.0']
  spec.add_dependency 'activesupport', ['>= 3.0', '< 5.0']
end
