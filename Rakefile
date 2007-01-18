require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_*.rb']
end

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'doc'
  rd.rdoc_files.include('lib/**/*.rb')
end
