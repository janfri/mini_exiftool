require 'exiftool'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end

class TestExiftoolRead < Test::Unit::TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @et = Exiftool.new  @data_dir + '/test.jpg'
  end

  def test_initialize
    assert_raises Exiftool::Error do
      Exiftool.new ''
    end
  end

  def test_access
    assert_equal 'DYNAX 7D', @et['Model']
    assert_equal 'MLT0', @et['maker_note_version']
    assert_equal 'MLT0', @et.maker_note_version
    assert_equal 400, @et.iso
  end

  def test_tags
    assert @et.tags.include?('FileSize')
  end

  def test_conversion
    assert_kind_of String, @et.model
    assert_kind_of Time, @et['DateTimeOriginal']
    assert_kind_of Float, @et['MaxApertureValue']
    assert_kind_of Fixnum, @et.flash
    assert_kind_of String, @et.exif_version
    assert_kind_of Fixnum, @et['ExposureCompensation']
    assert_kind_of Array, @et.image_size
    assert_kind_of Array, @et['SubjectLocation']
  end

end
