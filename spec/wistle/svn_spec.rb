require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "..", "lib", "wistle.rb" )

class MockArticle
  include DataMapper::Resource
  include Wistle::Svn
  
  property :id, Integer
  property :title, String
  property :contents, Text, :body_property => true
end

class MockArticleNoSvn
  include DataMapper::Resource
  
  property :id, Integer
  property :title, String
  property :contents, Text
end

describe Wistle::Svn do
  it "should add svn_* properties" do
    MockArticleNoSvn.properties['svn_created_at'].should be_nil
    MockArticleNoSvn.properties['svn_updated_at'].should be_nil
    MockArticleNoSvn.properties['svn_created_rev'].should be_nil
    MockArticleNoSvn.properties['svn_updated_rev'].should be_nil
    MockArticleNoSvn.properties['svn_created_by'].should be_nil
    MockArticleNoSvn.properties['svn_updated_by'].should be_nil

    MockArticle.properties['svn_created_at'].should be_kind_of(DataMapper::Property)
    MockArticle.properties['svn_updated_at'].should be_kind_of(DataMapper::Property)
    MockArticle.properties['svn_created_rev'].should be_kind_of(DataMapper::Property)
    MockArticle.properties['svn_updated_rev'].should be_kind_of(DataMapper::Property)
    MockArticle.properties['svn_created_by'].should be_kind_of(DataMapper::Property)
    MockArticle.properties['svn_updated_by'].should be_kind_of(DataMapper::Property)
    MockArticle.properties['path'].should be_kind_of(DataMapper::Property)
  end
  
  it "should assign @config to an instance of Wistle::Config" do
    c = MockArticle.config
    c.should be_kind_of(Wistle::Config)
    c.should be(MockArticle.config)
  end
  
  it "should add an :body_property options to including class" do
    MockArticle.config.body_property.should == "contents"
  end
  
  describe ".svn_repository" do
    before(:each) do
      @wistle_model = mock(Wistle::Model)
      @wistle_model.stub!(:config=)
      MockArticle.instance_variable_set("@svn_repository", nil)
    end
    
    it "should return an already set repository" do
      Wistle::Model.should_not_receive(:first)
      Wistle::Model.should_not_receive(:create)
      MockArticle.instance_variable_set("@svn_repository", @wistle_model)
      MockArticle.svn_repository.should be(@wistle_model)
    end
    
    it "should find an existing Wistle::Model" do
      Wistle::Model.should_receive(:first).with(:name => 'MockArticle').
          and_return(@wistle_model)
      Wistle::Model.should_not_receive(:create)
      MockArticle.svn_repository.should be(@wistle_model)
    end
    
    it "should create an new Wistle::Model if needed" do
      Wistle::Model.should_receive(:first).with(:name => 'MockArticle').
          and_return(nil)
      Wistle::Model.should_receive(:create).with(:name => 'MockArticle', :revision => 0).
          and_return(@wistle_model)
      MockArticle.svn_repository.should be(@wistle_model)
    end
    
    it "should really create a new Wistle::Model" do
      Wistle::Model.all.each {|m| m.destroy }
      Wistle::Model.count.should == 0
      MockArticle.svn_repository
      Wistle::Model.count.should == 1
      MockArticle.instance_variable_set("@svn_repository", nil)
      MockArticle.svn_repository
      Wistle::Model.count.should == 1
    end
    
    it "should assign @config to the Wistle::Model" do
      Wistle::Model.should_receive(:first).with(:name => 'MockArticle').
          and_return(@wistle_model)
      @wistle_model.should_receive(:config=).with(MockArticle.config)
      MockArticle.svn_repository
    end
    
    it "should run sync" do
      Wistle::Model.should_receive(:first).with(:name => 'MockArticle').
          and_return(@wistle_model)
      sync = mock(Wistle::SvnSync)
      Wistle::SvnSync.should_receive(:new).with(@wistle_model).and_return(sync)
      sync.should_receive(:run)
      MockArticle.sync
    end
    
  end
end
