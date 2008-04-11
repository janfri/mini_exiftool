require 'mini_exiftool'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
  begin
    require 'rubygems'
    require 'turn'
  rescue LoadError
  end
end

include Test::Unit
