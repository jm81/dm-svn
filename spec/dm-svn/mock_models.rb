require 'spec_helper'
require 'dm-svn'

class MockArticle
  include DataMapper::Resource
  include DmSvn::Svn
  
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
  include DmSvn::Svn
  
  property :id, Integer, :serial => true
  property :title, String
  property :body, Text, :body_property => true
  property :published_at, DateTime
  property :random_number, Integer # because some tests need a non-datetime prop
end

class MockCategory
  include DataMapper::Resource
  include DmSvn::Svn
  has n, :mock_categorized_articles
  
  property :id, Integer, :serial => true
  property :title, String
  property :random_number, Integer
end

class MockCategorizedArticle
  include DataMapper::Resource
  include DmSvn::Svn
  belongs_to :mock_category, :svn => true
  
  property :id, Integer, :serial => true
  property :title, String
  property :article, String
  property :body, Text, :body_property => true
  property :published_at, DateTime
  property :random_number, Integer # because some tests need a non-datetime prop
end
