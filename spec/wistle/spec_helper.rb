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
end
