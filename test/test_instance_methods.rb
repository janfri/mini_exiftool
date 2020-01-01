# -- encoding: utf-8 --
require 'helpers_for_test'

class TestRead < TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test.jpg'
    @mini_exiftool = MiniExiftool.new @filename_test
  end

  def test_respond_to_missing
    assert_true @mini_exiftool.respond_to?(:iso), 'instance should respond to iso because it has a value for ISO'
    assert_true @mini_exiftool.respond_to?('iso'), 'instance should respond to iso because it has a value for ISO'
    assert_true @mini_exiftool.respond_to?('ISO'), 'instance should respond to ISO because it has a value for ISO'
    assert_true @mini_exiftool.respond_to?(:iso=), 'instance should respond to iso= because all setters are allowed'
    assert_true @mini_exiftool.respond_to?('iso='), 'instance should respond to iso= because all setters are allowed'
    assert_true @mini_exiftool.respond_to?('ISO='), 'instance should respond to ISO= because all setters are allowed'
    assert_false @mini_exiftool.respond_to?(:comment), 'instance should not respond to comment because it has no value for Comment'
    assert_false @mini_exiftool.respond_to?('comment'), 'instance should not respond to comment because it has no value for Comment'
    assert_false @mini_exiftool.respond_to?('Comment'), 'instance should not respond to Comment because it has no value for Comment'
  end

end
