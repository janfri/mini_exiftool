require 'exiftool'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end

class TestExiftoolRead < Test::Unit::TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test.jpg'
    @exiftool = Exiftool.new @filename_test
    @exiftool_num = Exiftool.new @filename_test, true
  end

  def test_initialize
    assert_raises Exiftool::Error do
      Exiftool.new ''
    end
  end

  def test_initialize
    assert_raises Exiftool::Error do
      Exiftool.new 'not_existing_file'
    end
  end

  def test_access
    assert_equal 'DYNAX 7D', @exiftool['Model']
    assert_equal 'MLT0', @exiftool['maker_note_version']
    assert_equal 'MLT0', @exiftool.maker_note_version
    assert_equal 400, @exiftool.iso
  end

  def test_access_numerical
    assert_equal 'DYNAX 7D', @exiftool_num['Model']
    assert_equal 'MLT0', @exiftool_num['maker_note_version']
    assert_equal 'MLT0', @exiftool_num.maker_note_version
    assert_equal 400, @exiftool_num.iso
  end

  def test_tags
    assert @exiftool_num.tags.include?('FileSize')
  end

  def test_conversion
    assert_kind_of String, @exiftool.model
    assert_kind_of Time, @exiftool['DateTimeOriginal']
    assert_kind_of Float, @exiftool['MaxApertureValue']
    assert_kind_of String, @exiftool.flash
    assert_kind_of Fixnum, @exiftool['ExposureCompensation']
    assert_kind_of Array, @exiftool['SubjectLocation']
  end

  def test_conversion_numerical
    assert_kind_of String, @exiftool_num.model
    assert_kind_of Time, @exiftool_num['DateTimeOriginal']
    assert_kind_of Float, @exiftool_num['MaxApertureValue']
    assert_kind_of Fixnum, @exiftool_num.flash
    assert_kind_of String, @exiftool_num.exif_version
    assert_kind_of Fixnum, @exiftool_num['ExposureCompensation']
    assert_kind_of Array, @exiftool_num['SubjectLocation']
  end

  def test_class_methods
    assert_equal 'DYNAX 7D', Exiftool.model(@filename_test)
    assert_equal 'MLT0', Exiftool.maker_note_version(@filename_test)
  end

end
