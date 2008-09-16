require File.expand_path(File.join( File.dirname(__FILE__), "..", "spec_helper" ))
require File.expand_path(File.join( File.dirname(__FILE__), "..", "..", "lib", "wistle.rb" ))

class MockArticle
  include DataMapper::Resource
  include Wistle::Svn
  
  property :id, Integer, :serial => true
  property :title, String
  property :contents, Text, :body_property => true
end

class MockArticleNoSvn
  include DataMapper::Resource
  
  property :id, Integer, :serial => true
  property :title, String
  property :contents, Text
end

class MockSyncModel
  include DataMapper::Resource
  include Wistle::Svn
  
  property :id, Integer, :serial => true
  property :title, String
  property :body, Text, :body_property => true
  property :published_at, DateTime
  property :random_number, Integer # because some tests need a non-datetime prop
end

# Load a fixture and return the repos uri.
def load_svn_fixture(name)
  require(File.join(File.dirname(__FILE__), "fixtures", "#{name}.rb" ))
  repos_path = File.join(File.dirname(__FILE__), "..", "..", "lib", "wistle", "tmp", "repo_#{name}" )
  return "file://" + File.expand_path(repos_path) + "/articles"
end