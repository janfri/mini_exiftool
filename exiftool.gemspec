require 'rubygems'

spec = Gem::Specification.new do |spec|
  spec.name = 'exiftool'
  spec.version = '0.2.0'
  spec.summary = 'A library for nice OO access to the Exiftool program written by Phil Harvey.'
  spec.description = <<END
This library is a binding to the Exiftool program
(http://www.sno.phy.queensu.ca/~phil/exiftool/) written by Phil Harvay.
The binding is done by calling the commandline application with various
parameters and parsing the result.
END
  spec.author = 'Jan Friedrich'
  spec.email = 'janfri@web.de'
  spec.test_files = Dir['test/*.rb']
  spec.files = Dir['lib/*.rb'] + Dir['test/data/test.jpg']
end
