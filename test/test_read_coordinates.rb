# -- encoding: utf-8 --
require 'helpers_for_test'

class TestReadCoordinates < TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test_coordinates.jpg'
  end

  def test_access_coordinates
    mini_exiftool_coord = MiniExiftool.new @filename_test, :coord_format => "%.6f degrees"
    assert_match /^43.653167 degrees/, mini_exiftool_coord['GPSLatitude']
    assert_match /^79.373167 degrees/, mini_exiftool_coord['GPSLongitude']
    assert_match /^43.653167 degrees.*, 79.373167 degrees/, mini_exiftool_coord['GPSPosition']
  end

end
