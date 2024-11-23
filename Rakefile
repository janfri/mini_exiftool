require 'rim/tire'
require 'rim/version'
require 'rim/regtest'

Rim.setup do |p|
  p.test_warning = false
  if p.feature_loaded? 'rim/aspell'
    p.aspell_files << 'Tutorial.md'
  end
end
