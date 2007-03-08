require 'digest/md5'
require 'mini_exiftool'
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
    @temp_file.close
    @temp_filename = @temp_file.path
    @org_filename = File.dirname(__FILE__) + '/data/test.jpg'
    FileUtils.cp(@org_filename, @temp_filename)
    @mini_exiftool = MiniExiftool.new @temp_filename
    @mini_exiftool_num = MiniExiftool.new @temp_filename, :numerical => true
  end

  def teardown
    @temp_file.delete
  end

  def test_access_existing_tags
    assert_equal 'Horizontal (normal)', @mini_exiftool['Orientation']
    @mini_exiftool['Orientation'] = 'some string'
    assert_equal 'some string', @mini_exiftool['Orientation']
    assert_equal false, @mini_exiftool.changed?('Orientation')
    @mini_exiftool['Orientation'] = 2
    assert_equal 2, @mini_exiftool['Orientation']
    assert @mini_exiftool.changed_tags.include?('Orientation')
    @mini_exiftool.save
    assert_equal 'Mirror horizontal', @mini_exiftool['Orientation']
    @mini_exiftool_num.reload
    assert_equal 2, @mini_exiftool_num['Orientation']
  end

  def test_access_existing_tags_numerical
    assert_equal 1, @mini_exiftool_num['Orientation']
    @mini_exiftool_num['Orientation'] = 2
    assert_equal 2, @mini_exiftool_num['Orientation']
    assert_equal 2, @mini_exiftool_num.orientation
    @mini_exiftool_num.orientation = 3
    assert_equal 3, @mini_exiftool_num.orientation
    assert @mini_exiftool_num.changed_tags.include?('Orientation')
    @mini_exiftool_num.save
    assert_equal 3, @mini_exiftool_num['Orientation']
    @mini_exiftool.reload
    assert_equal 'Rotate 180', @mini_exiftool['Orientation']
  end

  def test_access_non_writable_tags
    @mini_exiftool_num['FileSize'] = 1
    assert_equal true, @mini_exiftool_num.changed?
    @mini_exiftool_num['SomeNonWritableName'] = 'test'
    assert_equal true, @mini_exiftool_num.changed?
  end

  def test_time_conversion
    t = Time.now
    @mini_exiftool_num['DateTimeOriginal'] = t
    assert_kind_of Time, @mini_exiftool_num['DateTimeOriginal']
    assert true, @mini_exiftool_num.changed_tags.include?('DateTimeOriginal')
    @mini_exiftool_num.save
    assert_equal false, @mini_exiftool_num.changed?
    assert_kind_of Time, @mini_exiftool_num['DateTimeOriginal']
    assert_equal t.to_s, @mini_exiftool_num['DateTimeOriginal'].to_s
  end

  def test_float_conversion
    assert_kind_of Float, @mini_exiftool_num['ExposureTime']
    new_time = @mini_exiftool_num['ExposureTime'] * 2.0
    @mini_exiftool_num['ExposureTime'] = new_time
    assert_equal new_time, @mini_exiftool_num['ExposureTime']
    assert true, @mini_exiftool_num.changed_tags.include?('ExposureTime')
    @mini_exiftool_num.save
    assert_kind_of Float, @mini_exiftool_num['ExposureTime']
    assert_equal new_time, @mini_exiftool_num['ExposureTime']
  end

  def test_integer_conversion
    assert_kind_of Integer, @mini_exiftool_num['MeteringMode']
    new_mode = @mini_exiftool_num['MeteringMode'] - 1
    @mini_exiftool_num['MeteringMode'] = new_mode
    assert_equal new_mode, @mini_exiftool_num['MeteringMode']
    assert @mini_exiftool_num.changed_tags.include?('MeteringMode')
    @mini_exiftool_num.save
    assert_equal new_mode, @mini_exiftool_num['MeteringMode']
  end

  def test_revert_one
    @mini_exiftool_num['Orientation'] = 2
    @mini_exiftool_num['ISO'] = 200
    res = @mini_exiftool_num.revert 'Orientation'
    assert_equal 1, @mini_exiftool_num['Orientation']
    assert_equal 200, @mini_exiftool_num['ISO']
    assert_equal true, res
    res = @mini_exiftool_num.revert 'Orientation'
    assert_equal false, res
  end

  def test_revert_all
    @mini_exiftool_num['Orientation'] = 2
    @mini_exiftool_num['ISO'] = 200
    res = @mini_exiftool_num.revert
    assert_equal 1, @mini_exiftool_num['Orientation']
    assert_equal 400, @mini_exiftool_num['ISO']
    assert_equal true, res
    res = @mini_exiftool_num.revert
    assert_equal false, res
  end

end
