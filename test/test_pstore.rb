# -- encoding: utf-8 --
require 'helpers_for_test'

class TestPstore < TestCase

  def test_pstore
    pstore_dir = Dir.mktmpdir
    writable_tags = MiniExiftool.writable_tags
    res = execute(pstore_dir)
    t1 = res['time']
    assert_equal writable_tags, res['writable_tags']
    assert_equal 1, Dir[File.join(pstore_dir, '*')].size
    res = execute(pstore_dir)
    t2 = res['time']
    assert_equal writable_tags, res['writable_tags']
    assert t2 < 1.0, format('loading cached tag information should be done in under 1 second but needed %.2fs', t2)
    assert 10 * t2 < t1, format('loading cached tag information (%.2fs) should be 10 times faster than loading uncached information (%.2fs)', t2, t1)
  ensure
    FileUtils.rm_rf pstore_dir
  end

  private

  def execute pstore_dir
    script = <<-END
      MiniExiftool.pstore_dir = '#{pstore_dir}'
      res = {}
      start = Time.now
      res['writable_tags'] = MiniExiftool.writable_tags
      res['time'] = Time.now - start
      puts YAML.dump res
    END
    cmd = %Q(#{RUBY_ENGINE} -EUTF-8 -I lib -r mini_exiftool -r yaml -e "#{script}")
    YAML.load(`#{cmd}`)
  end

end
