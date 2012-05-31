# -- encoding: utf-8 --
require 'helpers_for_test'

class TestBadPreviewIFD < TestCase

  include TempfileTest

  def setup
    super
    @org_filename = @data_dir + '/Bad_PreviewIFD.jpg'
    FileUtils.cp @org_filename, @temp_filename
    @bad_preview_ifd = MiniExiftool.new @temp_filename
  end

  # Feature request rubyforge [#29587]
  # Thanks to Michael Grove for reporting
  def test_m_option
    title = 'anything'
    @bad_preview_ifd.title = title
    assert_equal false, @bad_preview_ifd.save, '-m option seems to be not neccessary'
    @bad_preview_ifd.reload
    @bad_preview_ifd.title = title
    @bad_preview_ifd.ignore_minor_errors = true
    assert_equal true, @bad_preview_ifd.save, 'Error while saving'
    @bad_preview_ifd.reload
    assert_equal title, @bad_preview_ifd.title
  end

end
