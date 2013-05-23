# -- encoding: utf-8 --
require 'helpers_for_test'

class TestReadCoordinates < TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test_coordinates.jpg'
  end

  def test_access_coordinates
    mini_exiftool_coord = MiniExiftool.new @filename_test, :coord_format => "%+.6f"
    # checking float equality is here ok ;-)
    assert_equal +43.653167, mini_exiftool_coord['GPSLatitude']
    assert_equal -79.373167, mini_exiftool_coord['GPSLongitude']
    assert_equal '+43.653167, -79.373167', mini_exiftool_coord['GPSPosition']
  end

end
