# -- encoding: utf-8 --
require 'helpers_for_test'

class TestBadOutputEncoding < TestCase

  include TempfileTest

  def setup
    super
    @filename = @data_dir + '/Bad_Output_Encoding.jpg'
  end

  def test_bad_output_encoding
    assert_nothing_raised(ArgumentError) { @mini_exiftool = MiniExiftool.new @filename }
    assert_equal @mini_exiftool['Comment'], 'File written by Adobe Photoshop 4.0'
  end

end
