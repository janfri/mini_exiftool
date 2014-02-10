# -- encoding: utf-8 --
require 'mini_exiftool'

if ARGV.size < 2
  puts "usage: ruby #{__FILE__} SOURCE_FILE TARGET_FILE"
  exit -1
end

source_filename, target_filename = ARGV

begin
  photo = MiniExiftool.new filename
  # The second parameter of MiniExiftool#copy_tags_from
  # could be a String, Symbol or an Array of Strings,
  # Symbols
  photo.copy_tags_from(target, 'icc_profile')
rescue MiniExiftool::Error => e
  $stderr.puts e.message
  exit -1
end
