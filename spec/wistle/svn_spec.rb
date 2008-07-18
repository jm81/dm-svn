require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "..", "lib", "wistle.rb" )

class MockArticle
  include DataMapper::Resource
  include Wistle::Svn
  
  property :id, Integer
  property :title, String
  property :body, Text
end

class MockArticleNoSvn
  include DataMapper::Resource
  
  property :id, Integer
  property :title, String
  property :body, Text
end

describe Wistle::Svn do
  it "should add svn_* properties" do
    MockArticleNoSvn.properties['svn_created_at'].should be_nil
    MockArticleNoSvn.properties['svn_updated_at'].should be_nil
    MockArticleNoSvn.properties['svn_created_rev'].should be_nil
    MockArticleNoSvn.properties['svn_updated_rev'].should be_nil

    MockArticle.properties['svn_created_at'].should be_kind_of(DataMapper::Property)
    MockArticle.properties['svn_updated_at'].should be_kind_of(DataMapper::Property)
    MockArticle.properties['svn_created_rev'].should be_kind_of(DataMapper::Property)
    MockArticle.properties['svn_updated_rev'].should be_kind_of(DataMapper::Property)
  end
end
