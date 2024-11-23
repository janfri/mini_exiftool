# encoding: utf-8
require_relative 'lib/mini_exiftool'

Gem::Specification.new do |s|
  s.name = 'mini_exiftool'
  s.version = MiniExiftool::VERSION

  s.author = 'Jan Friedrich'
  s.email = 'janfri26@gmail.com'

  s.license = 'LGPL-2.1'

  s.summary = 'This library is a wrapper for the ExifTool command-line application (https://exiftool.org).'
  s.description = <<~END
    This library is a wrapper for the ExifTool command-line application\n(https://exiftool.org) written by Phil Harvey.
    It provides the full power of ExifTool to Ruby: reading and writing of\nEXIF-data, IPTC-data and XMP-data.
  END
  s.homepage = 'https://github.com/janfri/mini_exiftool'

  s.metadata = {
    'source_code_uri' => s.homepage
  }

  s.require_paths = 'lib'
  s.files = %w[COPYING Changelog README.md Tutorial.md] + Dir['examples/**/*'] + Dir['lib/*.rb']

  s.post_install_message = <<~END
    +-----------------------------------------------------------------------+
    | Please ensure you have installed exiftool at least version 7.65       |
    | and it's found in your PATH (Try 'exiftool -ver' on your commandline).|
    | For more details see                                                  |
    | https://exiftool.org/install.html                                     |
    | You need also Ruby 1.9 or higher.                                     |
    | If you need support for Ruby < 1.9 or exiftool < 7.65 then install    |
    | mini_exiftool version < 2.0.0.                                        |
    +-----------------------------------------------------------------------+
  END

  s.required_ruby_version = '>= 1.9'
  s.requirements << 'exiftool, version >= 7,65'

  s.add_runtime_dependency('ostruct', '>= 0.6.0')
  s.add_runtime_dependency('pstore', '>= 0.1.3')

  s.add_development_dependency('rake', '>= 0')
  s.add_development_dependency('rim', '~> 3.0')
  s.add_development_dependency('test-unit', '>= 0')
  s.add_development_dependency('regtest', '~> 2')
end
