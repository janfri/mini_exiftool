require 'digest/md5'
require 'exiftool'
require 'fileutils'
require 'tempfile'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end

class TestExiftoolWrite < Test::Unit::TestCase

  def setup
    @temp_file = Tempfile.new('test')
    @temp_filename = @temp_file.path
    @org_filename = File.dirname(__FILE__) + '/data/test.jpg'
    FileUtils.cp(@org_filename, @temp_filename)
    @et = Exiftool.new @temp_filename
  end

  def teardown
    @temp_file.close
  end

  def test_write_access_1
    assert_equal 1, @et['Orientation']
    @et['Orientation'] = 2
    assert_equal 2, @et['Orientation']
    assert_equal 2, @et.orientation
    @et.orientation = 3
    assert_equal 3, @et.orientation
  end

  def test_write_access_2
    @et['FileSize'] = 1
    assert @et.changed_tags.empty?
    @et['Orientation'] = 2
    assert true, @et.changed_tags.include?('Orientation')
  end


  def test_save
    org_md5 = Digest::MD5.hexdigest(File.read(@org_filename))
    temp_md5 = Digest::MD5.hexdigest(File.read(@temp_filename))
    assert_equal org_md5, temp_md5
    @et['Orientation'] = 2
    @et.save
    org_md5_2 = Digest::MD5.hexdigest(File.read(@org_filename))
    assert_equal org_md5, org_md5_2
    temp_md5_2 = Digest::MD5.hexdigest(File.read(@temp_filename))
    assert_not_equal temp_md5, temp_md5_2
    assert @et.changed_tags.empty?
  end

end
