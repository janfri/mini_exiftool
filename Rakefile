require 'rim/tire'
require 'rim/version'
require 'rim/regtest'

$:.unshift 'lib'
require 'mini_exiftool'

Rim.setup do |p|
  p.name = 'mini_exiftool'
  p.version = MiniExiftool::VERSION
  p.authors = 'Jan Friedrich'
  p.email = 'janfri26@gmail.com'
  p.summary = 'This library is a wrapper for the ExifTool command-line application (https://exiftool.org).'
  p.description <<-END
This library is a wrapper for the ExifTool command-line application
(https://exiftool.org) written by Phil Harvey.
It provides the full power of ExifTool to Ruby: reading and writing of
EXIF-data, IPTC-data and XMP-data.
  END
  p.homepage = 'https://github.com/janfri/mini_exiftool'
  p.license = 'LGPL-2.1'
  p.gem_files << 'Tutorial.md'
  p.gem_files += FileList.new('examples/**')
  p.install_message = <<-END
+-----------------------------------------------------------------------+
| Please ensure you have installed exiftool at least version 7.65       |
| and it's found in your PATH (Try "exiftool -ver" on your commandline).|
| For more details see                                                  |
| https://exiftool.org/install.html             |
| You need also Ruby 1.9 or higher.                                     |
| If you need support for Ruby 1.8 or exiftool prior 7.65 install       |
| mini_exiftool version < 2.0.0.                                        |
+-----------------------------------------------------------------------+
  END
  p.test_warning = false
  p.development_dependencies << 'test-unit'
  if p.feature_loaded? 'rim/aspell'
    p.aspell_files << 'Tutorial.md'
  end
end
