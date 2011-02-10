require 'helpers_for_test'

class TestEscapeFilename < TestCase

  def setup
    @temp_file = Tempfile.new('test')
    @temp_file.close
    @temp_filename = @temp_file.path
    @org_filename = File.dirname(__FILE__) + '/data/test 36"Bench.jpg'
    FileUtils.cp(@org_filename, @temp_filename)
    @mini_exiftool = MiniExiftool.new @temp_filename
  end

  def test_access
    assert_equal '36" Bench', @mini_exiftool['description']
  end

  def test_save
    desc = 'another bench'
    @mini_exiftool.description = desc
    assert @mini_exiftool.save
    assert_equal desc, @mini_exiftool.description
  end

end
