require 'rubygems'
require 'mini_exiftool'

if ARGV.size < 2
  puts "usage: ruby #{__FILE__} [+|-]SECONDS FILES"
  puts " i.e.: ruby #{__FILE__} 3600 *.jpg"
  exit -1
end

delta = ARGV.shift.to_i

ARGV.each do |filename|
  begin
    photo = MiniExiftool.new filename
  rescue MiniExiftool::Error => e
    $stderr.puts e.message
    exit -1
  end
  time = photo.date_time_original
  # time is a Time object, so we can use the methods of it :)
  time += delta
  photo.date_time_original = time
  save_ok = photo.save
  if save_ok
    puts "#{filename} changed"
  else
    puts "#{filename} could not be changed"
  end
end
