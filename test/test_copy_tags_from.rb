# -- encoding: utf-8 --
require 'helpers_for_test'

class TestCopyTagsFrom < TestCase

  include TempfileTest

  def setup
    super
    @canon_filename = @data_dir + '/Canon.jpg'
    FileUtils.cp(@canon_filename, @temp_filename)
    @mini_exiftool = MiniExiftool.new(@temp_filename)
    @source_filename = @data_dir + '/test.jpg'
    @canon_md5 = Digest::MD5.hexdigest(File.read(@canon_filename))
    @source_md5 = Digest::MD5.hexdigest(File.read(@source_filename))
  end

  def test_single_tag
    assert_nil @mini_exiftool.title
    res = @mini_exiftool.copy_tags_from(@source_filename, :title)
    assert res
    assert_equal 'Abenddämmerung', @mini_exiftool.title
    assert_md5 @source_md5, @source_filename
  end

  def test_more_than_one_tag
    assert_nil @mini_exiftool.title
    assert_nil @mini_exiftool.keywords
    res = @mini_exiftool.copy_tags_from(@source_filename, %w[title keywords])
    assert res
    assert_equal 'Abenddämmerung', @mini_exiftool.title
    assert_equal %w[Orange Rot], @mini_exiftool.keywords
    assert_md5 @source_md5, @source_filename
  end

  def test_non_existing_sourcefile
    assert_raises MiniExiftool::Error do
      @mini_exiftool.copy_tags_from('non_existend_file', :title)
    end
    assert_md5 @source_md5, @source_filename
  end

  def test_non_existend_tag
    @mini_exiftool.copy_tags_from(@source_filename, :non_existend_tag)
    assert_md5 @canon_md5, @canon_filename
    assert_md5 @source_md5, @source_filename
  end

  def test_non_writable_tag
    @mini_exiftool.copy_tags_from(@source_filename, 'JFIF')
    assert_md5 @canon_md5, @canon_filename
    assert_md5 @source_md5, @source_filename
  end

end
