# -- encoding: utf-8 --
require 'helpers_for_test'
require 'tmpdir'

class TestFilenameAccess < TestCase


  @@fs_enc = Encoding.find('filesystem')

  def create_testfile(basename_new)
    tmpdir = Dir.tmpdir
    filename_org = File.join(File.dirname(__FILE__), 'data/test.jpg')
    filename_new = File.join(tmpdir, basename_new)
    FileUtils.cp filename_org, filename_new.encode(@@fs_enc)
    filename_new
  end

  def do_testing_with(basename)
    filename_test = create_testfile(basename)
    # read
    m = MiniExiftool.new filename_test
    assert_equal 400, m.iso
    # save
    m.iso = 200
    m.save
    assert_equal 200, m.iso
    # Check original filename maybe with other encoding than filesystem
    assert_equal basename, File.basename(m.filename)
  rescue Exception => e
    assert false, "File #{filename_test.inspect} not found!"
  end

  def test_access_filename_with_spaces
    do_testing_with 'filename with spaces.jpg'
  end

  def test_access_filename_with_special_chars
    do_testing_with 'filename_with_Ümläüts.jpg'
  end

  def test_access_filename_with_doublequotes
    do_testing_with 'filename_with_"doublequotes"_inside.jpg'
  end

  def test_access_filename_with_dollar_sign
    do_testing_with 'filename_with_$_sign.jpg'
  end

  def test_access_filename_with_ampersand
    do_testing_with 'filename_with_&_sign.jpg'
  end

end
