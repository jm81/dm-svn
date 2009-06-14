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

class MockCategory
  include DataMapper::Resource
  include Wistle::Svn
  has n, :mock_categorized_articles
  
  property :id, Integer, :serial => true
  property :title, String
  property :random_number, Integer
end

class MockCategorizedArticle
  include DataMapper::Resource
  include Wistle::Svn
  belongs_to :mock_category, :wistle => true
  
  property :id, Integer, :serial => true
  property :title, String
  property :article, String
  property :body, Text, :body_property => true
  property :published_at, DateTime
  property :random_number, Integer # because some tests need a non-datetime prop
end
