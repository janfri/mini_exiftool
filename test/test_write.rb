require 'digest/md5'
require 'exiftool'
require 'fileutils'
require 'tempfile'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end

class TestWrite < Test::Unit::TestCase

  def setup
    @temp_file = Tempfile.new('test')
    @temp_filename = @temp_file.path
    @org_filename = File.dirname(__FILE__) + '/data/test.jpg'
    FileUtils.cp(@org_filename, @temp_filename)
    @exiftool = Exiftool.new @temp_filename
    @exiftool_num = Exiftool.new @temp_filename, :numerical
  end

  def teardown
    @temp_file.close
  end

  def test_access_existing_tags
    assert_equal 'Horizontal (normal)', @exiftool['Orientation']
    @exiftool['Orientation'] = 'some string'
    assert_equal 'Horizontal (normal)', @exiftool['Orientation']
    assert_equal false, @exiftool.changed?('Orientation')
    @exiftool['Orientation'] = 2
    assert_equal 2, @exiftool['Orientation']
    assert @exiftool.changed_tags.include?('Orientation')
    @exiftool.save
    assert_equal 'Mirror horizontal', @exiftool['Orientation']
    @exiftool_num.reload
    assert_equal 2, @exiftool_num['Orientation']
  end

  def test_access_existing_tags_numerical
    assert_equal 1, @exiftool_num['Orientation']
    @exiftool_num['Orientation'] = 2
    assert_equal 2, @exiftool_num['Orientation']
    assert_equal 2, @exiftool_num.orientation
    @exiftool_num.orientation = 3
    assert_equal 3, @exiftool_num.orientation
    assert @exiftool_num.changed_tags.include?('Orientation')
    @exiftool_num.save
    assert_equal 3, @exiftool_num['Orientation']
    @exiftool.reload
    assert_equal 'Rotate 180', @exiftool['Orientation']
  end

  def test_access_not_existing_tags
    @exiftool_num['FileSize'] = 1
    assert_equal false, @exiftool_num.changed?
    @exiftool_num['SomeNotExitingName'] = 'test'
    assert_equal false, @exiftool_num.changed?
  end

  def test_time_conversion
    t = Time.now
    @exiftool_num['DateTimeOriginal'] = t
    assert_kind_of Time, @exiftool_num['DateTimeOriginal']
    assert true, @exiftool_num.changed_tags.include?('DateTimeOriginal')
    @exiftool_num.save
    assert_equal false, @exiftool_num.changed?
    assert_kind_of Time, @exiftool_num['DateTimeOriginal']
    assert_equal t.to_s, @exiftool_num['DateTimeOriginal'].to_s
  end

  def test_float_conversion
    assert_kind_of Float, @exiftool_num['ExposureTime']
    new_time = @exiftool_num['ExposureTime'] * 2.0
    @exiftool_num['ExposureTime'] = new_time
    assert_equal new_time, @exiftool_num['ExposureTime']
    assert true, @exiftool_num.changed_tags.include?('ExposureTime')
    @exiftool_num.save
    assert_kind_of Float, @exiftool_num['ExposureTime']
    assert_equal new_time, @exiftool_num['ExposureTime']
  end

  def test_integer_conversion
    assert_kind_of Integer, @exiftool_num['MeteringMode']
    new_mode = @exiftool_num['MeteringMode'] - 1
    @exiftool_num['MeteringMode'] = new_mode
    assert_equal new_mode, @exiftool_num['MeteringMode']
    assert @exiftool_num.changed_tags.include?('MeteringMode')
    @exiftool_num.save
    assert_equal new_mode, @exiftool_num['MeteringMode']
  end

  def test_save
    org_md5 = Digest::MD5.hexdigest(File.read(@org_filename))
    temp_md5 = Digest::MD5.hexdigest(File.read(@temp_filename))
    assert_equal org_md5, temp_md5
    @exiftool_num['Orientation'] = 2
    @exiftool_num.save
    org_md5_2 = Digest::MD5.hexdigest(File.read(@org_filename))
    assert_equal org_md5, org_md5_2
    temp_md5_2 = Digest::MD5.hexdigest(File.read(@temp_filename))
    assert_not_equal temp_md5, temp_md5_2
    assert_equal false, @exiftool_num.changed?
  end

end
