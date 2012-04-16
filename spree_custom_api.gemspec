Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_custom_api'
  s.version     = '0.60.4'
  s.summary     = 'Add gem summary here'
  s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

   s.author            = 'Railsfactory'
   s.email             = 'info@railsfactory.com'
   s.homepage          = 'http://www.railsfactory.com/'
   s.rubyforge_project = 'api'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency('spree_core', '>= 0.60.4')
end
