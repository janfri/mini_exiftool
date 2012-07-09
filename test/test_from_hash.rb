require 'helpers_for_test'
require 'json'

class TestFromHash < TestCase
  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    hash_data = JSON.parse(File.read( @data_dir + '/test.jpg.json')).first
    @mini_exiftool = MiniExiftool.from_hash hash_data
  end

  def test_conversion
    assert_kind_of String, @mini_exiftool.model
    assert_kind_of Time, @mini_exiftool['DateTimeOriginal']
    assert_kind_of Float, @mini_exiftool['MaxApertureValue']
    assert_kind_of String, @mini_exiftool.flash
    assert_kind_of Fixnum, @mini_exiftool['ExposureCompensation']
    assert_kind_of String, (@mini_exiftool['SubjectLocation'] || @mini_exiftool['SubjectArea'])
    assert_kind_of Array, @mini_exiftool['Keywords']
    assert_kind_of String, @mini_exiftool['SupplementalCategories']
    assert_kind_of Rational, @mini_exiftool.shutterspeed
  end
end
