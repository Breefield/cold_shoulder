Gem::Specification.new do |s|
  s.name        = 'cold_shoulder'
  s.version     = '1.0.3'
  s.date        = '2013-11-13'
  s.summary     = "Validate that there is no contact information in a field"
  s.description = "Rails validation gem which ensures no contact information can be passed through a field. Contact information is twitter handles, email addresses, and phone numbers."
  s.authors     = ["Dustin Hoffman"]
  s.email       = 'dustin.hoffman@breefield.com'
  s.files       = ["lib/cold_shoulder.rb"]
  s.homepage    = 'https://github.com/Breefield/cold_shoulder'
  s.license     = 'MIT'

  
  s.add_runtime_dependency 'activemodel'
  s.add_runtime_dependency 'activesupport'

  # For testing
  s.add_development_dependency 'rspec'
end