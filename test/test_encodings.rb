# -- encoding: utf-8 --
require 'helpers_for_test'

class TestEncodings < TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test_encodings.jpg'
    @mini_exiftool = MiniExiftool.new @filename_test
  end

  def test_iptc_encoding
    object_name = "Möhre"
    assert_not_equal object_name, @mini_exiftool.object_name
    correct_iptc = MiniExiftool.new(@filename_test, iptc_encoding: 'MacRoman')
    assert_equal object_name, correct_iptc.object_name
  end

end
