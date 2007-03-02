require 'digest/md5'
require 'mini_exiftool'
require 'fileutils'
require 'tempfile'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end

class TestSave < Test::Unit::TestCase

  def setup
    @temp_file = Tempfile.new('test')
    @temp_file.close
    @temp_filename = @temp_file.path
    @org_filename = File.dirname(__FILE__) + '/data/test.jpg'
    FileUtils.cp(@org_filename, @temp_filename)
    @mini_exiftool = MiniExiftool.new @temp_filename
    @mini_exiftool_num = MiniExiftool.new @temp_filename, :numerical => true
    @org_md5 = Digest::MD5.hexdigest(File.read(@org_filename))
  end

  def test_allowed_value
    assert_equal @org_md5, @org_md5
    @mini_exiftool_num['Orientation'] = 2
    result = @mini_exiftool_num.save
    assert_equal true, result
    assert_equal @org_md5, Digest::MD5.hexdigest(File.read(@org_filename))
    assert_not_equal @org_md5, Digest::MD5.hexdigest(File.read(@temp_filename))
    assert_equal false, @mini_exiftool_num.changed?
    result = @mini_exiftool_num.save
    assert_equal false, result
  end

  def test_save_non_allowed_value
    org_orientation = @mini_exiftool['Orientation']
    @mini_exiftool['Orientation'] = 'some string'
    result = @mini_exiftool.save
    assert_equal org_orientation, @mini_exiftool['Orientation']
    assert_equal false, result
    assert_equal 1, @mini_exiftool.errors.size
    assert_equal("Can't convert IFD0:Orientation (not in PrintConv)",
                 @mini_exiftool.errors['Orientation'])
  end

  def test_no_changing_of_file_when_error
    @mini_exiftool['ISO'] = 800
    @mini_exiftool['Orientation'] = 'some value'
    @mini_exiftool['ExposureTime'] = '1/30'
    result = @mini_exiftool.save
    assert_equal false, result
    assert_equal @org_md5, Digest::MD5.hexdigest(File.read(@org_filename))
    assert_equal @org_md5, Digest::MD5.hexdigest(File.read(@temp_filename))
  end

end
