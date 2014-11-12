# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'mini_exiftool'

Gem::Specification.new do |spec|
  spec.name          = "mini_exiftool"
  spec.platform      = Gem::Platform::RUBY
  spec.version       = MiniExiftool::VERSION
  spec.authors       = ["Jan Friedrich"]
  spec.email         = "janfri26@gmail.com"
  spec.homepage      = "https://github.com/janfri/mini_exiftool"
  spec.summary       = "This library is wrapper for the Exiftool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool)."
  spec.description   = "This library is wrapper for the Exiftool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool)."
  spec.date          = "2012-05-31"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = ["README.rdoc", "Tutorial.rdoc", "lib/mini_exiftool.rb"]
  spec.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Mini_exiftool", "--main", "README.rdoc"]
  spec.post_install_message = "\n+-----------------------------------------------------------------------+\n| Please ensure you have installed exiftool and it's found in your PATH |\n| (Try \"exiftool -ver\" on your commandline). For more details see       |\n| http://www.sno.phy.queensu.ca/~phil/exiftool/install.html             |\n+-----------------------------------------------------------------------+\n  "

	spec.required_rubygems_version = Gem::Requirement.new(">= 1.2") if spec.respond_to?(:required_rubygems_version=)
  spec.add_dependency 'rim'
  spec.add_dependency 'json'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0" #because rake test is easy
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "regtest"
  spec.add_development_dependency "mocha" #for stubbing return values
end
