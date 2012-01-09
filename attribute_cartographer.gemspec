# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "attribute_cartographer/version"

Gem::Specification.new do |s|
  s.name        = "attribute_cartographer"
  s.version     = AttributeCartographer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kris Hicks"]
  s.email       = ["krishicks@gmail.com"]
  s.homepage    = "https://github.com/krishicks/attribute-cartographer"
  s.summary     = %q{Map an attributes hash to methods on Ruby object while transforming the values to suit.}
  s.description = %q{AttributeCartographer allows you to map an attributes hash into similarly or differently named methods, using an optional lambda to map the values as well.}

  s.add_development_dependency('rake')
  s.add_development_dependency('autotest')
  s.add_development_dependency('rspec', '>= 2.5')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

