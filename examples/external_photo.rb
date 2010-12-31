# -- encoding: utf-8 --
require 'open-uri'
require 'rubygems'
require 'mini_exiftool'

unless ARGV.size == 1
  puts "usage: ruby #{__FILE__} URI"
  puts " i.e.: ruby #{__FILE__} http://www.23hq.com/janfri/photo/1535332/large"
  exit -1
end

# Fetch an external photo
filename = open(ARGV.first).path

# Read the metadata
photo = MiniExiftool.new filename

# Print the metadata
photo.tags.sort.each do |tag|
#  puts "#{tag}: #{photo[tag]}"
  puts tag.ljust(28) + photo[tag].to_s
end
