$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "monster_mithril/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "monster-mithril"
  s.version     = MonsterMithril::VERSION
  s.authors     = ["Monsterbox Productions"]
  s.email       = ["andrew@monsterboxpro.com"]
  s.homepage    = "http://monsterboxpro.com"
  s.summary     = 'A specical flavour of mithril, to make isomorphic mithril apps in Rails'
  s.description = 'A specical flavour of mithril, to make isomorphic mithril apps in Rails'
  s.license     = "MIT"

  s.files = Dir["{app lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.3"
  s.add_dependency 'libv8'
end
