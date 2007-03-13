require 'rubygems'
require 'mini_exiftool'

unless ARGV.size > 0
  puts "usage: ruby #{__FILE__} FILES"
  puts " i.e.: ruby #{__FILE__} *.jpg"
  exit -1
end

# Loop at all given files
ARGV.each do |filename|
  # If a given file isn't a photo MiniExiftool new method will throw
  # an exception this we will catch
  begin
    photo = MiniExiftool.new filename
    height = photo.image_height
    width  = photo.image_width
    # We define portait as a photo wich ratio of height to width is 
    # larger than 0.7
    if height / width > 0.7
      puts filename
    end
  rescue MiniExiftool::Error => e
    $stderr.puts e.message
  end
end
