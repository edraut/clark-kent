$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "clark_kent/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "clark_kent"
  s.version     = ClarkKent::VERSION
  s.authors     = ["Eric Draut"]
  s.email       = ["edraut@gmail.com"]
  s.homepage    = "https://github.com/edraut/clark-kent"
  s.summary     = "A powerful reporting engine for Rails apps."
  s.description = "A powerful reporting engine for Rails apps."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.1.0"
  s.add_dependency "simple_form"
  s.add_dependency "kaminari"
  s.add_dependency "thin_man"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest"
end
