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
  s.description = "Get an ad hoc report building UI for any model from your app that you configure for ClarkKent."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 5.1", "< 6"
  s.add_dependency "sass-rails", "< 6"
  s.add_dependency "simple_form", ">= 3.2.1", "< 4.0"
  s.add_dependency "kaminari", "<= 1"
  s.add_dependency "thin_man", ">= 0.12.2", "< 1.0"
  s.add_dependency "foreign_office", ">= 0.10.3", "< 1.0"
  s.add_dependency "hooch", ">= 0.15.1" , "< 1.0"
  s.add_dependency 'aws-sdk-v1', "< 2"

  s.add_development_dependency "sqlite3", "< 2"
  s.add_development_dependency "minitest", "< 6"
  s.add_development_dependency "minitest-rails", ">= 3", "< 4"
  s.add_development_dependency "pry-rails", "< 1"
  s.add_development_dependency "pry-nav", "< 1"
  s.add_development_dependency "pry-remote", "< 1"
  s.add_development_dependency "jquery-rails"
end
