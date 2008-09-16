require File.join( File.dirname(__FILE__), "spec_helper" )

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
  
  describe '#path=' do
    before(:each) do
      @article = MockArticle.new
    end
    
    it "should set svn_name" do
      @article.should_receive(:attribute_set).with(:svn_name, 'short/path')
      @article.path = 'short/path'
    end
    
  end
  
  describe '#update_from_svn' do
    before(:each) do
      @node = mock(Wistle::Svn::Node)
      @article = MockArticle.new
    end
    
    it 'should update path, body and other properties' do
      @node.should_receive(:body).and_return('body')      
      @node.should_receive(:short_path).and_return('short/path')
      @node.should_receive(:properties).and_return(
        {'title' => 'Title', 'svn_updated_by' => 'jmorgan'}
      )
      
      @article.should_receive(:attribute_set).with(:svn_name, 'short/path')
      @article.should_receive(:attribute_set).with('contents', 'body')
      @article.should_receive(:attribute_set).with('title', 'Title')
      @article.should_receive(:attribute_set).with('svn_updated_by', 'jmorgan')
      
      @article.should_receive(:save)
      @article.update_from_svn(@node)
    end

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
      sync = mock(Wistle::Svn::Sync)
      Wistle::Svn::Sync.should_receive(:new).with(@wistle_model).and_return(sync)
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
      a = Article.new
      
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
