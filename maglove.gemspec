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
  s.homepage    = "https://github.com/MagLoft/maglove"
  s.summary     = "MagLove - MagLoft Theme Toolkit."
  s.description = "This gem contains development and built tools for creating MagLoft themes."
  s.required_rubygems_version = '>= 2.4.7'
  s.add_runtime_dependency "bundler", "~> 1.10"
  s.add_runtime_dependency 'haml', ">= 4.0", "< 6.0"
  s.add_runtime_dependency "thor", "~> 0.19"
  s.add_runtime_dependency 'hamloft', "~> 0.2"
  s.add_runtime_dependency "activesupport", ">= 4.0", "< 6.0"
  s.add_runtime_dependency "actionpack", ">= 4.0", "< 6.0"
  s.add_runtime_dependency "maglove-widgets", "~> 1.1"
  s.add_runtime_dependency "open_uri_redirections", "~> 0.2"
  s.add_runtime_dependency "logging", "~> 2.0"
  s.add_runtime_dependency "tilt", "~> 1.4"
  s.add_runtime_dependency "coffee-script", "~> 2.4"
  s.add_runtime_dependency "less", "~> 2.6"
  s.add_runtime_dependency "therubyracer", "~> 0.12"
  s.add_runtime_dependency "sass", "~> 3.4"
  s.add_runtime_dependency "sass-css-importer", ">= 1.0.0.beta.0"
  s.add_runtime_dependency "dialers", "~> 0.2"
  s.add_runtime_dependency "rubyzip", "~> 1.1"
  s.add_runtime_dependency "image_optim", "~> 0.21"
  s.add_runtime_dependency "crush", "~> 0.3"
  s.add_runtime_dependency "closure-compiler", "~> 1.1"
  s.add_runtime_dependency "cssminify", "~> 1.0"
  s.add_runtime_dependency "image_optim_pack", "~> 0.2"
  s.add_runtime_dependency "puma", "~> 3.6"
  s.add_runtime_dependency "filewatcher", "~> 0.5"
  s.add_runtime_dependency "faye", "~> 1.2"
  s.add_runtime_dependency "typhoeus", "~> 1.1"
  s.add_development_dependency "rubocop", "~> 0.32"
  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path = 'lib'
end
