# encoding: utf-8
require 'helpers_for_test'
require 'pathname'


class TestPathname < TestCase
  
  include TempfileTest
  
  def setup
    super
    @org_filename = @data_dir + '/test.jpg'
    FileUtils.cp(@org_filename, @temp_filename)
    @temp_pathname = Pathname.new(@temp_filename)
    @mini_exiftool = MiniExiftool.new @temp_pathname
  end

  def test_pathname
    assert_equal 400, @mini_exiftool.iso
    @mini_exiftool.iso = 200
    assert_equal true, @mini_exiftool.save
    mini_exiftool = MiniExiftool.new(@temp_pathname)
    assert_equal 200, @mini_exiftool.iso
    @mini_exiftool.iso = 300
    assert_nothing_raised do
      @mini_exiftool.save!
    end
    assert_equal 300, @mini_exiftool.iso
  end

end
