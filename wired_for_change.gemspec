Gem::Specification.new do |s|
  s.name        = "wired_for_change"
  s.version     = "0.0.2"
  s.licenses    = ['MIT']
  s.author      = "Akshat Pradhan"
  s.email       = "contact@actblue.com"
  s.homepage    = "http://github.com/actblue/wired_for_change"
  s.summary     = "Track donors through Salsa Labs"
  s.description = "Track donors through Salsa Labs using this Gem"
  s.files        = Dir["lib/**/*", "[A-Z]*"] - ["Gemfile.lock"]
  s.require_path = "lib"
  s.add_development_dependency "rdoc", "~> 3.12"
  s.add_development_dependency "jeweler", "~> 1.8.3"
end