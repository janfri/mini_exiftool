require 'mini_exiftool'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end

class TestOther < Test::Unit::TestCase

  def test_command
    cmd = MiniExiftool.command
    assert_equal 'exiftool', cmd
    MiniExiftool.command = 'non_existend'
    assert_equal 'non_existend', MiniExiftool.command
    assert_raises MiniExiftool::Error do
      met = MiniExiftool.new(File.join(File.dirname(__FILE__), 
                                       'data/test.jpg'))
    end
    MiniExiftool.command = cmd
  end

  def test_writable_tags
    w_tags = MiniExiftool.writable_tags
    assert w_tags.include?('ISO')
    assert_equal false, w_tags.include?('xxxxxx')
  end

end
