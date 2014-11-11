# -- encoding: utf-8 --
require 'helpers_for_test'

class TestPStore < TestCase

  # def setup
  #   @temp_file = Tempfile.new('test')
  #   @temp_file.close
  #   @temp_filename = @temp_file.path
  #   @org_filename = File.dirname(__FILE__) + '/data/test.jpg'
  #   FileUtils.cp(@org_filename, @temp_filename)
  #   @mini_exiftool = MiniExiftool.new @temp_filename
  #   #@mini_exiftool_num = MiniExiftool.new @temp_filename, :numerical => true
  # end

  # def teardown
  #   @temp_file.delete
  # end

  def test_host_os
	  MiniExiftool.stubs(:host_os).returns(nil)
	  assert_equal nil, MiniExiftool.host_os

	  MiniExiftool.stubs(:host_os).returns('test')
	  assert_equal 'test', MiniExiftool.host_os

	  MiniExiftool.stubs(:host_os).returns('Linux')
	  assert_equal 'Linux', MiniExiftool.host_os
	ensure
	  MiniExiftool.unstub(:host_os)
  end

  def test_running_on_windows?
	  MiniExiftool.stubs(:host_os).returns(nil)
	  assert !MiniExiftool.running_on_windows?

	  MiniExiftool.stubs(:host_os).returns('darwin13.4.0')
	  assert !MiniExiftool.running_on_windows?

	  MiniExiftool.stubs(:host_os).returns('mswin')
	  assert MiniExiftool.running_on_windows?

	  MiniExiftool.stubs(:host_os).returns('mingw')
	  assert MiniExiftool.running_on_windows?

	  MiniExiftool.stubs(:host_os).returns('cygwin')
	  assert MiniExiftool.running_on_windows?
	ensure
	  MiniExiftool.unstub(:host_os)
  end

	def test_home_path
	  assert_instance_of String, MiniExiftool.home_path
	  assert_not_equal '/', MiniExiftool.home_path
	end

	def test_pstore_file_path_writer
	  MiniExiftool.pstore_file_path = '/my/sbin/binary'
	  assert_equal '/my/sbin/binary', MiniExiftool.pstore_file_path
	end

	def test_default_pstore_file_path
		MiniExiftool.stubs(:running_on_windows?).returns(false)
		assert_equal '.mini_exiftool',File.basename(File.dirname(MiniExiftool.pstore_file_path))

		MiniExiftool.pstore_file_path = nil
	  MiniExiftool.stubs(:running_on_windows?).returns(true)
	  assert_equal '_mini_exiftool', File.basename(File.dirname(MiniExiftool.pstore_file_path))
	ensure
		MiniExiftool.unstub(:running_on_windows?)
	end
end
