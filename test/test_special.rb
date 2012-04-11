# -- encoding: utf-8 --
require 'helpers_for_test'

class TestSpecial < TestCase

  include TempfileTest

  CAPTION_ABSTRACT =  'Some text for caption abstract'

  def setup
    super
    @org_filename = @data_dir + '/Canon.jpg'
    FileUtils.cp @org_filename, @temp_filename
    @canon = MiniExiftool.new @temp_filename
  end

  # Catching bug [#8073]
  # Thanks to Eric Young
  def test_special_chars
    assert_not_nil @canon['Self-timer']
    assert_not_nil @canon.self_timer
    # preserving the original tag name
    assert @canon.tags.include?('Self-timer') || @canon.tags.include?('SelfTimer')
    assert !@canon.tags.include?('self_timer')
  end

  # Catching bug with writing caption-abstract
  # Thanks to Robin Romahn
  def test_caption_abstract_sensitive
    @canon['caption-abstract'] = CAPTION_ABSTRACT
    assert @canon.changed_tags.include?('Caption-Abstract')
    assert @canon.save
    assert_equal CAPTION_ABSTRACT, @canon.caption_abstract
  end

  def test_caption_abstract_non_sesitive
    @canon.caption_abstract = CAPTION_ABSTRACT.reverse
    assert @canon.save
    assert_equal CAPTION_ABSTRACT.reverse, @canon.caption_abstract
  end

end
