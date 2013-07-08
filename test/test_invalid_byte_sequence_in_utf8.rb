# -- encoding: utf-8 --
require 'helpers_for_test'
require 'json'

# Thanks to Chris Salzberg (aka shioyama) and
# Robert May (aka robotmay) for precious hints

class TestInvalidByteSequenceInUtf8 < TestCase

  def setup
    @json = File.read(File.dirname(__FILE__) + '/data/invalid_byte_sequence_in_utf8.json')
  end

  def test_invalid_byte_sequence_gets_unconverted_value_with_invalid_encoding
    assert_nothing_raised do
      mini_exiftool = MiniExiftool.from_json(@json)
      assert_equal 1561, mini_exiftool.color_balance_unknown.size
    end
  end

  def test_replace_invalid_chars
    assert_nothing_raised do
      mini_exiftool = MiniExiftool.from_json(@json, :replace_invalid_chars => '')
      assert_equal 1036, mini_exiftool.color_balance_unknown.size
    end
  end

end
