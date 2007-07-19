require 'mini_exiftool'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end

class TestSpecial < Test::Unit::TestCase

  CAPTION_ABSTRACT =  'Some text for caption abstract'

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_canon = @data_dir + '/Canon.jpg'
    @canon = MiniExiftool.new @filename_canon
  end

  # Catching bug [#8073]
  # Thanks to Eric Young
  def test_special_chars
    assert_equal 0, @canon['Self-timer']
    assert_equal 0, @canon.self_timer
    # preserving the original tag name
    assert @canon.tags.include?('Self-timer')
    assert !@canon.tags.include?('self_timer')
  end

  # Catching bug with writing caption-abstract
  # Thanks to Robin Romahn
  def test_caption_abstract
    @canon['caption-abstract'] = CAPTION_ABSTRACT
    @canon.save
    puts @canon.errors
  end

end
