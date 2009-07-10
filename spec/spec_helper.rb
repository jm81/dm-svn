require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'wistle'

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
  script = File.expand_path(File.join(File.dirname(__FILE__), "wistle", "fixtures", "#{name}.rb" ))
  load script
  return SvnFixture.repo(name).uri + "/articles"
end
