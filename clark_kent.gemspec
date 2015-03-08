$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "clark_kent/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "clark_kent"
  s.version     = ClarkKent::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ClarkKent."
  s.description = "TODO: Description of ClarkKent."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.8"

  s.add_development_dependency "sqlite3"
end
