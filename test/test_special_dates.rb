# -- encoding: utf-8 --
require 'date'
require 'fileutils'
require 'tempfile'
require 'helpers_for_test'

class TestSpecialDates < TestCase

  def setup
    data_dir = File.dirname(__FILE__) + '/data'
    temp_file = Tempfile.new('test')
    temp_file.close
    @temp_filename = temp_file.path
    org_filename = data_dir + '/test_special_dates.jpg'
    FileUtils.cp org_filename, @temp_filename
    @mini_exiftool = MiniExiftool.new @temp_filename
    @mini_exiftool_datetime = MiniExiftool.new @temp_filename,
      :timestamps => DateTime
  end

  # Catching bug [#16328] (1st part)
  # Thanks to unknown
  def test_datetime
    datetime_original = @mini_exiftool.datetime_original 
    if datetime_original
      assert_kind_of Time, datetime_original
    else
      assert_equal false, datetime_original
    end
    assert_kind_of DateTime, @mini_exiftool_datetime.datetime_original
    assert_raise MiniExiftool::Error do
      @mini_exiftool.timestamps = String
      @mini_exiftool.reload
    end
    @mini_exiftool.timestamps = DateTime
    @mini_exiftool.reload
    assert_equal @mini_exiftool_datetime.datetime_original,
      @mini_exiftool.datetime_original
  end

  # Catching bug [#16328] (2nd part)
  # Thanks to Cecil Coupe
  def test_invalid_date
    assert_equal false, @mini_exiftool.modify_date
  end

  def test_time_zone
    s = '1961-08-13 12:08:25+01:00'
    assert_equal Time.parse(s), @mini_exiftool.preview_date_time
    assert_equal DateTime.parse(s),
      @mini_exiftool_datetime.preview_date_time
  end

end

