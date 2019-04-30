# -- encoding: utf-8 --
require 'mini_exiftool'
require 'test/unit'
require 'fileutils'
require 'tempfile'
require 'yaml'

include Test::Unit

module TempfileTest
  def setup
    @temp_file = Tempfile.new('test')
    @temp_filename = @temp_file.path
    @data_dir = File.dirname(__FILE__) + '/data'
  end

  def teardown
    @temp_file.close
  end

  def assert_md5 md5, filename
    assert_equal md5,  Digest::MD5.hexdigest(File.read(filename))
  end

end
