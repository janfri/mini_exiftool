# -- encoding: utf-8 --
require 'mini_exiftool'
require 'open3'

unless ARGV.size == 1
  puts "usage: ruby #{__FILE__} URI"
  puts " i.e.: ruby #{__FILE__} http://farm6.staticflickr.com/5015/5458914734_8fd3f33278_o.jpg"
  exit -1
end

arg = ARGV.shift

####################################
# Helper methods
####################################

def time
  a = Time.now
  yield
  b = Time.now
  b - a
end

def print_statistics name, without_fast, fast, fast2
  puts '-' * 40
  puts name, "\n"
  puts format 'without fast: %0.2fs', without_fast
  puts format 'fast        : %0.2fs', fast
  puts format 'fast2       : %0.2fs', fast2
  puts
  puts format 'speedup fast : %0.2f', without_fast / fast
  puts format 'speedup fast2: %0.2f', without_fast / fast2
  puts '-' * 40
  puts
end

####################################
# Plain Ruby with standard library
####################################

require 'net/http'

uri = URI(arg)

def read_from_http uri, io
  Thread.new(uri, io) do |uri, io|
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri
      http.request request do |response|
        response.read_body do |chunk|
          io.write chunk
        end
      end
    end
    io.close
  end
end

without_fast = time do
  output, input = IO.pipe
  read_from_http uri, input
  MiniExiftool.new output
end

fast = time do
  output, input = IO.pipe
  read_from_http uri, input
  MiniExiftool.new output, fast: true
end

fast2 = time do
  output, input = IO.pipe
  read_from_http uri, input
  MiniExiftool.new output, fast2: true
end

print_statistics 'net/http', without_fast, fast, fast2

####################################
# curl
####################################

without_fast = time do
  input, output = Open3.popen3("curl -s #{arg}")
  input.close
  MiniExiftool.new output
end

fast = time do
  input, output = Open3.popen3("curl -s #{arg}")
  input.close
  MiniExiftool.new output, fast: true
end

fast2 = time do
  input, output = Open3.popen3("curl -s #{arg}")
  input.close
  MiniExiftool.new output, fast2: true
end

print_statistics 'curl', without_fast, fast, fast2

####################################
# wget
####################################

without_fast = time do
  input, output = Open3.popen3("wget -q -O - #{arg}")
  input.close
  MiniExiftool.new output
end

fast = time do
  input, output = Open3.popen3("wget -q -O - #{arg}")
  input.close
  MiniExiftool.new output, fast: true
end

fast2 = time do
  input, output = Open3.popen3("wget -q -O - #{arg}")
  input.close
  MiniExiftool.new output, fast2: true
end

print_statistics 'wget', without_fast, fast, fast2

