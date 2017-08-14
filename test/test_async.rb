# -- encoding: utf-8 --
require 'helpers_for_test'

class TestAsync < TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test.jpg'
    @mini_exiftool = MiniExiftool.new
  end

  def test_load_async
    @mini_exiftool.start_load @filename_test
    @mini_exiftool.finish_load
    assert_equal 'DYNAX 7D', @mini_exiftool['Model']
  end
end
