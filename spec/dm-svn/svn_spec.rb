require 'spec_helper'
require 'dm-svn/mock_models'

describe DmSvn::Svn do
  before(:all) do
    DmSvn::Model.auto_migrate!
    MockArticle.auto_migrate!
  end
  
  before(:each) do
    @article = MockArticle.new
  end
  
  it "should add svn_* properties" do
    fields = %w{name created_at updated_at created_rev updated_rev created_by updated_by}
    fields.each do | field |
      MockArticleNoSvn.properties["svn_#{field}"].should be_nil
      MockArticle.properties["svn_#{field}"].should be_kind_of(DataMapper::Property)
    end
  end
  
  it "should assign @config to an instance of DmSvn::Config" do
    c = MockArticle.config
    c.should be_kind_of(DmSvn::Config)
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
  
  describe '#path=' do
    it "should set svn_name" do
      @article.should_receive(:attribute_set).with(:svn_name, 'short/path')
      @article.path = 'short/path'
    end
  end
  
  describe '#update_from_svn' do
    before(:each) do
      @node = mock(DmSvn::Svn::Node)
    end
    
    it 'should update path, body and other properties' do
      @node.should_receive(:body).twice.and_return('body')
      @node.should_receive(:short_path).and_return('short/path')
      @node.should_receive(:properties).and_return(
        {'title' => 'Title', 'svn_updated_by' => 'jmorgan'}
      )
      
      @article.should_receive(:attribute_set).with(:svn_name, 'short/path')
      @article.should_receive(:attribute_set).with('contents', 'body')
      @article.should_receive(:title=).with('Title')
      @article.should_receive(:svn_updated_by=).with('jmorgan')
      
      @article.should_receive(:save)
      @article.update_from_svn(@node)
    end

  end
  
  describe "#move_to" do
    it 'should update the path and save' do
      @article.should_receive(:path=).with('new/path')
      @article.should_receive(:save)
      @article.move_to('new/path')
    end
  end
  
  describe ".svn_repository" do
    before(:each) do
      @svn_model = mock(DmSvn::Model)
      @svn_model.stub!(:config=)
      MockArticle.instance_variable_set("@svn_repository", nil)
    end
    
    it "should return an already set repository" do
      DmSvn::Model.should_not_receive(:first)
      DmSvn::Model.should_not_receive(:create)
      MockArticle.instance_variable_set("@svn_repository", @svn_model)
      MockArticle.svn_repository.should be(@svn_model)
    end
    
    it "should find an existing DmSvn::Model" do
      DmSvn::Model.should_receive(:first).with(:name => 'MockArticle').
          and_return(@svn_model)
      DmSvn::Model.should_not_receive(:create)
      MockArticle.svn_repository.should be(@svn_model)
    end
    
    it "should create an new DmSvn::Model if needed" do
      DmSvn::Model.should_receive(:first).with(:name => 'MockArticle').
          and_return(nil)
      DmSvn::Model.should_receive(:create).with(:name => 'MockArticle', :revision => 0).
          and_return(@svn_model)
      MockArticle.svn_repository.should be(@svn_model)
    end
    
    it "should really create a new DmSvn::Model" do
      DmSvn::Model.all.each {|m| m.destroy }
      DmSvn::Model.count.should == 0
      MockArticle.svn_repository
      DmSvn::Model.count.should == 1
      MockArticle.instance_variable_set("@svn_repository", nil)
      MockArticle.svn_repository
      DmSvn::Model.count.should == 1
    end
    
    it "should assign @config to the DmSvn::Model" do
      DmSvn::Model.should_receive(:first).with(:name => 'MockArticle').
          and_return(@svn_model)
      @svn_model.should_receive(:config=).with(MockArticle.config)
      MockArticle.svn_repository
    end
    
    it "should run sync" do
      DmSvn::Model.should_receive(:first).with(:name => 'MockArticle').
          and_return(@svn_model)
      sync = mock(DmSvn::Svn::Sync)
      DmSvn::Svn::Sync.should_receive(:new).with(@svn_model).and_return(sync)
      sync.should_receive(:run)
      MockArticle.sync
    end
    
  end
  
  describe ".get" do
    it "should get instance by path" do
      MockArticle.should_receive(:get_by_path).
        with('path/to/name').
        and_return(nil)
      
      MockArticle.get('path/to/name')
    end
    
    it "should get instance by id" do
      MockArticle.should_not_receive(:get_by_path)
      MockArticle.should_receive(:first).and_return(nil)
      MockArticle.get(1)
    end
  end
  
  describe ".get_or_create" do
    it "should get an existing instance by path" do
      MockArticle.should_receive(:get_by_path).
        with('path/to/name').
        and_return(1)
      
      MockArticle.get_or_create('path/to/name').should == 1
    end
    
    it "should create a new instance, setting path" do
      MockArticle.should_receive(:get_by_path).
        with('path/to/name').
        and_return(nil)
      
      m = MockArticle.new
      MockArticle.should_receive(:create).and_return(m)
      
      MockArticle.get_or_create('path/to/name')
      m.path.should == 'path/to/name'
    end
  end
  
  describe ".get_by_path" do
    it "should get an instance by path" do
      MockArticle.should_receive(:first).
        with(:svn_name => 'path/to/name').
        and_return(nil)
        
      MockArticle.get_by_path('path/to/name')
    end
  end
  
  describe "hooks" do
    it "should update svn_created_* properties before create" do
      a = MockArticle.new
      
      a.svn_updated_at = Time.parse("2008-08-10 05:00:00")
      a.svn_updated_rev = 10
      a.svn_updated_by = "jmorgan"
      a.save
      
      at = a.svn_updated_at
      
      a.svn_created_at.should == at
      a.svn_created_rev.should == 10.to_s
      a.svn_created_by.should == "jmorgan"
      
      a.svn_updated_at = Time.parse("2008-08-12 05:00:00")
      a.svn_updated_rev = 12
      a.svn_updated_by = "someone_else"
      a.save
      
      # should not have changed.
      a.svn_created_at.should == at
      a.svn_created_rev.should == 10.to_s
      a.svn_created_by.should == "jmorgan"
    end
  end
end
