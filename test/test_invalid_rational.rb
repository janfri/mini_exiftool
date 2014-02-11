# -- encoding: utf-8 --
require 'helpers_for_test'

class TestInvalidRational < TestCase

  def test_rescue_from_invalid_rational
    mini_exiftool = MiniExiftool.from_json(File.read('test/data/invalid_rational.json'))
    assert_equal '1/0', mini_exiftool.user_comment
  rescue Exception
    assert false, 'Tag values of the form x/0 should not raise an Exception.'
  end

end
