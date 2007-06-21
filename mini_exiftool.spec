require 'rubygems'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'mini_exiftool'

spec = Gem::Specification.new do |spec|
  spec.name = 'mini_exiftool'
  spec.version = MiniExiftool::Version
  spec.summary = 'A library for nice OO access to the Exiftool command-line application written by Phil Harvey.'
  spec.description = <<END
This library is wrapper for the Exiftool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool/) written by Phil Harvey.
Read and write access is done in a clean OO manner.
END
  spec.author = 'Jan Friedrich'
  spec.email = 'miniexiftool@googlemail.com'
  spec.test_files = Dir['test/*.rb']
  spec.files = Dir['lib/*.rb'] + Dir['test/data/test.jpg']
end
