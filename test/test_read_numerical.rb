# -- encoding: utf-8 --
require 'helpers_for_test'

class TestReadNumerical < TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test.jpg'
    @mini_exiftool_num = MiniExiftool.new @filename_test, :numerical => true
  end

  def test_access_numerical
    assert_equal 'DYNAX 7D', @mini_exiftool_num['Model']
    assert_equal 'MLT0', @mini_exiftool_num['maker_note_version']
    assert_equal 'MLT0', @mini_exiftool_num[:MakerNoteVersion]
    assert_equal 'MLT0', @mini_exiftool_num[:maker_note_version]
    assert_equal 'MLT0', @mini_exiftool_num.maker_note_version
    assert_equal 400, @mini_exiftool_num.iso
  end

  def test_conversion_numerical
    assert_kind_of String, @mini_exiftool_num.model
    assert_kind_of Time, @mini_exiftool_num['DateTimeOriginal']
    assert_kind_of Float, @mini_exiftool_num['MaxApertureValue']
    assert_kind_of Fixnum, @mini_exiftool_num.flash
    assert_kind_of String, @mini_exiftool_num.exif_version
    assert_kind_of Fixnum, @mini_exiftool_num['ExposureCompensation']
    assert_kind_of String, (@mini_exiftool_num['SubjectLocation'] || @mini_exiftool_num['SubjectArea'])
    assert_kind_of Array, @mini_exiftool_num['Keywords']
    assert_kind_of String, @mini_exiftool_num['SupplementalCategories']
    assert_kind_of Array, @mini_exiftool_num['SupplementalCategories'].to_a
  end

end
