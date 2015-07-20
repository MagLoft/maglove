lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'maglove/version'

Gem::Specification.new do |s|
  s.name        = "maglove"
  s.version     = MagLove::VERSION
  s.licenses    = ["BSD-3-Clause"]
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tobias Strebitzer"]
  s.email       = ["tobias.strebitzer@magloft.com"]
  s.homepage    = "http://www.magloft.com"
  s.summary     = "MagLove - MagLoft Theme Toolkit."
  s.description = "This gem contains development and built tools for creating MagLoft themes."
  s.required_rubygems_version = '>= 2.4.7'
  s.add_runtime_dependency "bundler", "~> 1.10.5"
  s.add_runtime_dependency "dotenv", "~> 2.0.2"
  s.add_runtime_dependency 'haml', "~> 4.0.6"
  s.add_runtime_dependency "rubyzip", "~> 1.1.7"
  s.add_runtime_dependency "activesupport", "~> 4.2.3"
  s.add_runtime_dependency "logging", "~> 2.0.0"
  s.add_runtime_dependency "tilt", "~> 1.4.1"
  s.add_runtime_dependency "sprockets", "< 3.0.0"
  s.add_runtime_dependency "coffee-script", "~> 2.4.1"
  s.add_runtime_dependency "minitar", "~> 0.5.4"
  s.add_runtime_dependency "therubyracer", "~> 0.12.2"
  s.add_runtime_dependency "less", "~> 2.6.0"
  s.add_runtime_dependency "webrick", "~> 1.3.1"
  s.add_runtime_dependency "commander", "~> 4.3.4"
  s.add_runtime_dependency "filewatcher", "~> 0.5.1"
  s.add_development_dependency "rspec", "~> 3.3.0"
  s.add_development_dependency "pry", "~> 0.10.1"
  s.add_development_dependency "rubocop", "~> 0.32.1"
  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path = 'lib'
end
