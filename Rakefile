require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "dm-svn"
    gem.summary = %Q{Sync content from a Subversion repository to a DataMapper model}
    gem.description = %Q{dm-svn allows you to store data in a Subversion
repository, then sync that data to a DataMapper model (for example, to a
relational database. Essentially, it allows you app quicker access to the
Subversion data.}
    gem.email = "jmorgan@morgancreative.net"
    gem.homepage = "http://github.com/jm81/dm-svn"
    gem.authors = ["Jared Morgan"]
    gem.add_dependency('dm-core', '>= 0.10.0')
    gem.add_dependency('dm-aggregates', '>= 0.10.0')
    gem.add_dependency('dm-validations', '>= 0.10.0')
    gem.add_dependency('svn-fixture', '>= 0.1.2')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "dm-svn #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

