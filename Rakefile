require 'rubygems'
require 'echoe'

Echoe.new('mini_exiftool') do |p|
  p.author = 'Jan Friedrich'
  p.email = 'janfri26@gmail.com'
  p.summary = 'This library is wrapper for the Exiftool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool).'
  p.url = 'http://gitorious.org/mini_exiftool'
  p.rdoc_files = %w(README Tutorial lib/*.rb)
  p.install_message = %q{
+-----------------------------------------------------------------------+
| Please ensure you have installed exiftool and it's found in your PATH |
| (Try "exiftool -ver" on your commandline). For more details see       |
| http://www.sno.phy.queensu.ca/~phil/exiftool/install.html             |
+-----------------------------------------------------------------------+
  }
  p.changelog = 'Changelog'
  task :prerelease do
    require "#{File.dirname(__FILE__)}/lib/mini_exiftool"
    unless p.version == MiniExiftool::VERSION
      $stderr.puts "Version conflict: Release version is #{p.version} but MiniExiftool::VERSION is #{MiniExiftool::VERSION}."
      exit(1)
    end
  end
end
