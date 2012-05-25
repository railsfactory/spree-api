# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "spree_custom_api"
  s.version     = '1.1.0'
  s.authors     = "RailsFactory"
  s.email       = "spree@railsfactory.org"
  s.homepage    = "http://www.railsfactory.com"
  s.summary     = "spree_custom_api  actually consists of list of api's for Spree Version 1.1.0"
  s.description = "spree_custom_api is a complete open source e-commerce solution built with Ruby on Rails. It was originally developed by RailsFactory Team. Documentation for the existing api's can be viewed with the Url:- http://spree-apidoc.heroku.com"

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.1.0'
  s.add_dependency 'spree_auth', '~> 1.1.0'
  
  s.add_development_dependency 'capybara', '1.0.1'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'sqlite3'
end
