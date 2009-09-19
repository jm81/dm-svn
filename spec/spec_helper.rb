require 'spec'
require 'dm-svn'

gem 'jm81-svn-fixture'
require 'svn-fixture'

DataMapper.setup(:default, 'sqlite3::memory:')

Spec::Runner.configure do |config|
  
end

# for temporarily disabling one set of specs.
def dont_describe(*args)
  nil
end

# Load a fixture and return the repos uri.
def load_svn_fixture(name)
  script = File.expand_path(File.join(File.dirname(__FILE__), "dm-svn", "fixtures", "#{name}.rb" ))
  load script
  return SvnFixture.repo(name).uri + "/articles"
end
