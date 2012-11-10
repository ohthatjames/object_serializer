# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'object_serializer/version'

Gem::Specification.new do |gem|
  gem.name          = "object_serializer"
  gem.version       = ObjectSerializer::VERSION
  gem.authors       = ["James Hunt"]
  gem.email         = ["ohthatjames@gmail.com"]
  gem.description   = %q{Serialize Ruby objects}
  gem.summary       = %q{Move serialization out of the objects being serializing}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_development_dependency "rspec"
end
