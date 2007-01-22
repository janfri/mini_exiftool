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
    @mini_exiftool_num = MiniExiftool.new @filename_test, :numerical
  end

  def test_initialize
    assert_raises MiniExiftool::Error do
      MiniExiftool.new ''
    end
    assert_raises MiniExiftool::Error do
      MiniExiftool.new 'not_existing_file'
    end
  end

  def test_access
    assert_equal 'DYNAX 7D', @mini_exiftool['Model']
    assert_equal 'MLT0', @mini_exiftool['maker_note_version']
    assert_equal 'MLT0', @mini_exiftool.maker_note_version
    assert_equal 400, @mini_exiftool.iso
  end

  def test_access_numerical
    assert_equal 'DYNAX 7D', @mini_exiftool_num['Model']
    assert_equal 'MLT0', @mini_exiftool_num['maker_note_version']
    assert_equal 'MLT0', @mini_exiftool_num.maker_note_version
    assert_equal 400, @mini_exiftool_num.iso
  end

  def test_tags
    assert @mini_exiftool_num.tags.include?('FileSize')
  end

  def test_conversion
    assert_kind_of String, @mini_exiftool.model
    assert_kind_of Time, @mini_exiftool['DateTimeOriginal']
    assert_kind_of Float, @mini_exiftool['MaxApertureValue']
    assert_kind_of String, @mini_exiftool.flash
    assert_kind_of Fixnum, @mini_exiftool['ExposureCompensation']
    assert_kind_of Array, @mini_exiftool['SubjectLocation']
  end

  def test_conversion_numerical
    assert_kind_of String, @mini_exiftool_num.model
    assert_kind_of Time, @mini_exiftool_num['DateTimeOriginal']
    assert_kind_of Float, @mini_exiftool_num['MaxApertureValue']
    assert_kind_of Fixnum, @mini_exiftool_num.flash
    assert_kind_of String, @mini_exiftool_num.exif_version
    assert_kind_of Fixnum, @mini_exiftool_num['ExposureCompensation']
    assert_kind_of Array, @mini_exiftool_num['SubjectLocation']
  end

end
