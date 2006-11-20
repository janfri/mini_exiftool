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
    @tempfile = Tempfile.new('test')
    @data_dir = File.dirname(__FILE__) + '/data'
    FileUtils.cp(@data_dir + '/test.jpg', @tempfile.path)
    @et = Exiftool.new @tempfile.path
  end

  def teardown
    @tempfile.close
  end

  def test_write_access_1
    assert_equal 1, @et['Orientation']
    @et['Orientation'] = 2
    assert_equal 2, @et['Orientation']
  end

#  def test_write_access_2
#    assert_equal 1, @et[Orientation']
#    @et.orientation = 2
#    assert_equal 2, @et['Orientation']
#  end

end
