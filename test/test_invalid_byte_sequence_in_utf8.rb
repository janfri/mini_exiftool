# -- encoding: utf-8 --
require 'helpers_for_test'
require 'json'

class TestInvalidByteSequenceInUtf8 < TestCase

  def setup
    @json = File.read(File.dirname(__FILE__) + '/data/invalid_byte_sequence_in_utf8.json')
  end

  def test_invalid_byte_sequence_in_utf8_cause_error
    assert_raises ArgumentError do
      MiniExiftool.from_json(@json)
    end
  end

  def test_replace_invalid_chars
    assert_nothing_raised do
      mini_exiftool = MiniExiftool.from_json(@json, :replace_invalid_chars => '')
      assert_equal 1036, mini_exiftool.color_balance_unknown.size
    end
  end

end
