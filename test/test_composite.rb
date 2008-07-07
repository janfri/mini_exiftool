require 'helpers_for_test'

class TestComposite < TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test.jpg'
    @mini_exiftool = MiniExiftool.new @filename_test, :composite => false
    @mini_exiftool_c = MiniExiftool.new @filename_test
  end

  def test_composite_tags
    assert_equal false, @mini_exiftool.tags.include?('Aperture')
    assert_equal true, @mini_exiftool_c.tags.include?('Aperture')
    assert_equal 9.5, @mini_exiftool_c['Aperture']
  end

end
