require 'mini_exiftool'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end

class TestRead < Test::Unit::TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test.jpg'
    @mini_exiftool = MiniExiftool.new @filename_test
  end

  def test_access
    assert_equal 'DYNAX 7D', @mini_exiftool['Model']
    assert_equal 'MLT0', @mini_exiftool['maker_note_version']
    assert_equal 'MLT0', @mini_exiftool.maker_note_version
    assert_equal 400, @mini_exiftool.iso
  end

  def test_tags
    assert @mini_exiftool.tags.include?('FileSize')
  end

  def test_conversion
    assert_kind_of String, @mini_exiftool.model
    assert_kind_of Time, @mini_exiftool['DateTimeOriginal']
    assert_kind_of Float, @mini_exiftool['MaxApertureValue']
    assert_kind_of String, @mini_exiftool.flash
    assert_kind_of Fixnum, @mini_exiftool['ExposureCompensation']
    assert_kind_of Array, @mini_exiftool['SubjectLocation']
  end

end
