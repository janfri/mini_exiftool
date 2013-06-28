require 'rim'
require 'rim/check_version'
require 'rim/gem'
require 'rim/test'

$:.unshift 'lib'
require 'mini_exiftool'

Rim.setup do |p|
  p.name = 'mini_exiftool'
  p.version = MiniExiftool::VERSION
  p.authors = 'Jan Friedrich'
  p.email = 'janfri26@gmail.com'
  p.summary = 'This library is wrapper for the Exiftool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool).'
  p.homepage = 'http://gitorious.org/mini_exiftool'
  # p.gem_files << 'Tutorial.rdoc'
  p.install_message = %q{
+-----------------------------------------------------------------------+
| Please ensure you have installed exiftool at least version 7.65       |
| and it's found in your PATH (Try "exiftool -ver" on your commandline).|
| For more details see                                                  |
| http://www.sno.phy.queensu.ca/~phil/exiftool/install.html             |
| You need also Ruby 1.9 or higher.                                     |
| If you need support for Ruby 1.8 or exiftool prior 7.65 install       |
| mini_exiftool version < 2.0.0.                                        |
+-----------------------------------------------------------------------+
  }
end
