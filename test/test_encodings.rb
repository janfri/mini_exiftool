# -- encoding: utf-8 --
require 'helpers_for_test'

class TestEncodings < TestCase

  include TempfileTest

  def setup
    super
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test_encodings.jpg'
    @mini_exiftool = MiniExiftool.new @filename_test
    @object_name = "Möhre"
  end

  def test_iptc_encoding
    assert_not_equal @object_name, @mini_exiftool.object_name
    correct_iptc = MiniExiftool.new(@filename_test, iptc_encoding: 'MacRoman')
    assert_equal @object_name, correct_iptc.object_name
    FileUtils.cp(@filename_test, @temp_filename)
    correct_iptc_write = MiniExiftool.new(@temp_filename, iptc_encoding: 'MacRoman')
    caption = 'Das ist eine Möhre'
    correct_iptc_write.caption_abstract = caption
    correct_iptc_write.save!
    correct_iptc_write.reload
    assert_equal @object_name, correct_iptc_write.object_name
    assert_equal caption, correct_iptc_write.caption_abstract
  end

  def test_coded_character_set
    assert_nil @mini_exiftool.coded_character_set

    FileUtils.cp(@filename_test, @temp_filename)
    @mini_exiftool2 = MiniExiftool.new @temp_filename
    @mini_exiftool2.coded_character_set = 'utf8'
    caption = 'Das ist eine Möhre'
    @mini_exiftool2.caption_abstract = caption
    @mini_exiftool2.save!
    @mini_exiftool2.reload
    assert_equal 'UTF8', @mini_exiftool2.coded_character_set
    assert_equal caption, @mini_exiftool2.caption_abstract
    assert_not_equal @object_name, @mini_exiftool2.object_name

    @mini_exiftool2.object_name = @object_name
    @mini_exiftool2.save!
    @mini_exiftool2.reload
    assert_equal caption, @mini_exiftool2.caption_abstract
    assert_equal @object_name, @mini_exiftool2.object_name
  end

end
