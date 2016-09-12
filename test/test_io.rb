# -- encoding: utf-8 --
require 'helpers_for_test'
require 'stringio'

class TestIo < TestCase

  def test_simple_case
    io = open_real_io
    mini_exiftool = MiniExiftool.new(io)
    assert_equal false, io.closed?, 'IO should not be closed.'
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

  def test_fast_options
    $DEBUG = true
    s = StringIO.new
    $stderr = s
    MiniExiftool.new open_real_io
    s.rewind
    assert_match /^exiftool -j  "-"$/, s.read
    s = StringIO.new
    $stderr = s
    MiniExiftool.new open_real_io, :fast => true
    s.rewind
    assert_match /^exiftool -j -fast  "-"$/, s.read
    s = StringIO.new
    $stderr = s
    MiniExiftool.new open_real_io, :fast2 => true
    s.rewind
    assert_match /^exiftool -j -fast2  "-"$/, s.read
  ensure
    $DEBUG = false
    $stderr = STDERR
  end

  protected

  def open_real_io
    File.open(File.join(File.dirname(__FILE__), 'data', 'test.jpg'), 'r')
  end

end
