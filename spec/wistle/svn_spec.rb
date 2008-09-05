require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "..", "lib", "wistle.rb" )

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

describe Wistle::Svn do
  it "should add svn_* properties" do
    fields = %w{name created_at updated_at created_rev updated_rev created_by updated_by}
    fields.each do | field |
      lambda { MockArticleNoSvn.properties["svn_#{field}"] }.should raise_error(ArgumentError)
      MockArticle.properties["svn_#{field}"].should be_kind_of(DataMapper::Property)
    end
  end
  
  it "should assign @config to an instance of Wistle::Config" do
    c = MockArticle.config
    c.should be_kind_of(Wistle::Config)
    c.should be(MockArticle.config)
  end
  
  it "should add an :body_property options to including class" do
    MockArticle.config.body_property.should == "contents"
  end
  
  it "should alias svn_name as name" do
    m = MockArticle.new
    m.svn_name = 'path/to/name'
    m.name.should == 'path/to/name'
  end
  
  it "should alias svn_name as path" do
    m = MockArticle.new
    m.svn_name = 'path/to/name'
    m.path.should == 'path/to/name'
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
