require 'mini_exiftool'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end

class TestOther < Test::Unit::TestCase

  def test_writable_tags
    w_tags = MiniExiftool.writable_tags
    assert w_tags.include?('ISO')
    assert_equal false, w_tags.include?('xxxxxx')
  end

end
