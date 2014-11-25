# -- encoding: utf-8 --
require 'helpers_for_test'

class TestPstore < TestCase

  def test_pstore
    pstore_dir = Dir.mktmpdir
    s = MiniExiftool.writable_tags.size.to_s
    cmd = %Q(#{RUBY_ENGINE} -EUTF-8 -I lib -r mini_exiftool -e "MiniExiftool.pstore_dir = '#{pstore_dir}'; p MiniExiftool.writable_tags.size")
    a = Time.now
    result = `#{cmd}`
    b = Time.now
    assert_equal s, result.chomp
    assert_equal 1, Dir[File.join(pstore_dir, '*')].size
    c = Time.now
    result = `#{cmd}`
    d = Time.now
    assert_equal s, result.chomp
    assert 10 * (d - c) < (b - a)
  ensure
    FileUtils.rm_rf pstore_dir
  end

end
