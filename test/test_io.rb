# -- encoding: utf-8 --
require 'helpers_for_test'

class TestIo < TestCase

  def test_simple_case
    io = open_real_io
    mini_exiftool = MiniExiftool.new(io)
    assert io.closed?, 'IO should be closed after reading data.'
    assert_equal 400, mini_exiftool.iso
  end

  def test_non_readable_io
    assert_raises MiniExiftool::Error do
      begin
        MiniExiftool.new($stdout)
      rescue MiniExiftool::Error => e
        assert_equal 'IO is not readable.', e.message
        raise e
      end
    end
  end

  def test_no_writing_when_using_io
    io = open_real_io
    m = MiniExiftool.new(io)
    m.iso = 100
    assert_raises MiniExiftool::Error do
      begin
        m.save
      rescue MiniExiftool::Error => e
        assert_equal 'No writing support when using an IO.', e.message
        raise e
      end
    end
  end

  protected

  def open_real_io
    File.open(File.join(File.dirname(__FILE__), 'data', 'test.jpg'), 'r')
  end

end
