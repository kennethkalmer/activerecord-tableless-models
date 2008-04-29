require 'rake/rdoctask'

task :default do
  puts
  puts IO.read( File.dirname(__FILE__) + '/README' )
  puts
end

Rake::RDocTask.new do |rd|
  rd.main = 'README'
  rd.rdoc_files.include( 'README', 'lib/*.rb', 'lib/**/*.rb' )
  rd.rdoc_dir = 'rdoc'
  rd.title = 'ActiveRecord Tableless Models'
end