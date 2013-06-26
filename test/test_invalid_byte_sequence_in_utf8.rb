# -- encoding: utf-8 --
require 'helpers_for_test'
require 'json'

class TestInvalidByteSequenceInUtf8 < TestCase

  def setup
    @hash = JSON.parse(File.read(File.dirname(__FILE__) + '/data/invalid_byte_sequence_in_utf8.json')).first
  end

  def test_invalid_byte_sequence_in_utf8_cause_error
    assert_raises ArgumentError do
      MiniExiftool.from_hash(@hash)
    end
  end

end
