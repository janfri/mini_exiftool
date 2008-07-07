require 'helpers_for_test'
require 'yaml'

class TestDumping < TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test.jpg'
    @mini_exiftool = MiniExiftool.new @filename_test
  end

  def test_to_hash
    hash = @mini_exiftool.to_hash
    assert_equal Hash, hash.class
    assert_equal @mini_exiftool.tags.size, hash.size, 'Size of Hash is not correct.'
    assert_not_nil hash['ExifToolVersion'], 'Original name of exiftool tag is not preserved.'
    all_ok = true
    diffenent_tag = ''
    hash.each do |k,v|
      unless @mini_exiftool[k] == v
        all_ok = false
        diffenent_tag = k
        break
      end
    end
    assert all_ok, "Tag #{diffenent_tag}: expected: #{@mini_exiftool[diffenent_tag]}, actual: v"
  end

  def test_from_hash
    hash = @mini_exiftool.to_hash
    mini_exiftool_new = MiniExiftool.from_hash hash
    assert_equal MiniExiftool, mini_exiftool_new.class
    assert_equal @mini_exiftool.tags.size, mini_exiftool_new.tags.size
    all_ok = true
    diffenent_tag = ''
    @mini_exiftool.tags.each do |tag|
      unless @mini_exiftool[tag] == mini_exiftool_new[tag]
        all_ok = false
        diffenent_tag = tag
        break
      end
    end
    assert all_ok, "Tag #{diffenent_tag}: expected: #{@mini_exiftool[diffenent_tag]}, actual: #{mini_exiftool_new[diffenent_tag]}"

  end

  def test_to_yaml
    hash = @mini_exiftool.to_hash
    yaml = @mini_exiftool.to_yaml
    assert_equal hash, YAML.load(yaml)
  end

  def test_from_yaml
    hash = @mini_exiftool.to_hash
    yaml = hash.to_yaml
    mini_exiftool_new = MiniExiftool.from_yaml(yaml)
    assert_equal MiniExiftool, mini_exiftool_new.class
    assert_equal hash, mini_exiftool_new.to_hash
  end

  def test_heuristics_for_restoring_composite
    standard = @mini_exiftool.to_hash
    no_composite = MiniExiftool.new(@filename_test, :composite => false).to_hash
    assert_equal true, MiniExiftool.from_hash(standard).composite
    assert_equal false, MiniExiftool.from_hash(no_composite).composite
    assert_equal true, MiniExiftool.from_yaml(standard.to_yaml).composite
    assert_equal false, MiniExiftool.from_yaml(no_composite.to_yaml).composite
  end

  def test_heuristics_for_restoring_numerical
    standard = @mini_exiftool.to_hash
    numerical = MiniExiftool.new(@filename_test, :numerical => true).to_hash
    assert_equal false, MiniExiftool.from_hash(standard).numerical
    assert_equal true, MiniExiftool.from_hash(numerical).numerical
    assert_equal false, MiniExiftool.from_yaml(standard.to_yaml).numerical
    assert_equal true, MiniExiftool.from_yaml(numerical.to_yaml).numerical
  end

  def test_heuristics_for_restoring_timestamps
    standard = @mini_exiftool.to_hash
    timestamps = MiniExiftool.new(@filename_test, :timestamps => DateTime).to_hash
    assert_equal Time, MiniExiftool.from_hash(standard).timestamps
    assert_equal DateTime, MiniExiftool.from_hash(timestamps).timestamps
    # Doesn't work yet.
    # assert_equal Time, MiniExiftool.from_yaml(standard.to_yaml).timestamps
    # assert_equal DateTime, MiniExiftool.from_yaml(timestamps.to_yaml).timestamps
  end

end
