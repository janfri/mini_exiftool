require 'helpers_for_test'

class TestClassMethods < TestCase

  def test_new
    assert_nothing_raised do
      @mini_exiftool = MiniExiftool.new
    end
    assert_equal nil, @mini_exiftool.filename
    assert_nothing_raised do
      MiniExiftool.new nil
    end
    assert_raises MiniExiftool::Error do
      MiniExiftool.new false 
    end
    assert_raises MiniExiftool::Error do
      MiniExiftool.new ''
    end
    assert_raises MiniExiftool::Error do
      MiniExiftool.new 'not_existing_file'
    end
    assert_raises MiniExiftool::Error do
      MiniExiftool.new '.' # directory
    end
    begin
      MiniExiftool.new 'not_existing_file'
    rescue MiniExiftool::Error => e
      assert_match /File 'not_existing_file' does not exist/, e.message
    end
    assert_raises MiniExiftool::Error do
      MiniExiftool.new __FILE__ # file type wich Exiftool can not handle
    end
    begin
      MiniExiftool.new __FILE__ # file type wich Exiftool can not handle
    rescue MiniExiftool::Error => e
      assert_match /Error: Unknown (?:image|file) type/, e.message
    end
  end

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

  def test_opts
    opts = MiniExiftool.opts
    assert_kind_of Hash, opts
    begin
      org = MiniExiftool.opts[:composite]
      met1 = MiniExiftool.new
      MiniExiftool.opts[:composite] = !org
      met2 = MiniExiftool.new
      MiniExiftool.opts[:composite] = org
      met3 = MiniExiftool.new
      assert_equal org, met1.composite
      assert_equal !org, met2.composite
      assert_equal org, met1.composite
    ensure
      MiniExiftool.opts[:composite] = org
    end
  end

  def test_all_tags
    all_tags = MiniExiftool.all_tags
    assert all_tags.include?('ISO')
    assert all_tags.include?('OriginalFilename')
  end

  def test_writable_tags
    w_tags = MiniExiftool.writable_tags
    assert w_tags.include?('ISO')
    assert_equal false, w_tags.include?('xxxxxx')
  end

  def test_exiftool_version
    v = MiniExiftool.exiftool_version
    assert_match /\A\d+\.\d+\z/, v
  end

end
