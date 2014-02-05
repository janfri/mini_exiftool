require 'mini_exiftool'
require 'regtest'

Dir['test/data/*.jpg'].sort.each do |fn|
  Regtest.sample 'read ' << File.basename(fn) do
    h = MiniExiftool.new(fn).to_hash
    %w(ExifToolVersion FileModifyDate FileAccessDate FileInodeChangeDate FilePermissions).each do |tag|
      h.delete(tag)
    end
    h
  end
end
