require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Wistle::Svn::Categorized do
  before(:all) do
    Wistle::Model.auto_migrate!
    MockCategory.auto_migrate!
    MockCategorizedArticle.auto_migrate!
  end
  
  before(:each) do
    MockCategory.all.each { |m| m.destroy }
  end
  
  describe ".belongs_to" do
    it "should initialize @svn_category" do
      MockCategorizedArticle.instance_variable_get('@svn_category').should ==
        :mock_category
    end
    
    it 'should initialize @svn_category_model' do
      MockCategorizedArticle.instance_variable_get('@svn_category_model').should ==
        'MockCategory'
    end
  end
  
  it '.svn_category should get name of category (as method name)' do
    MockCategorizedArticle.svn_category.should == :mock_category
  end
  
  it '.svn_category_model should get name of category (as constant)' do
    MockCategorizedArticle.svn_category_model.should == 'MockCategory'
  end
  
  describe "#path" do
    before(:each) do
      @article = MockCategorizedArticle.new(:svn_name => 'article')
      @category = MockCategory.new(:svn_name => 'cat/path')
      @article.mock_category = @category
    end
    
    it "should append @svn_name to svn_category.path" do
      @article.path.should == 'cat/path/article'
    end
    
    it "should return just @svn_name if svn_category.path is blank" do
      @category.path = ''
      @article.path.should == 'article'
    end
    
    it "should return just @svn_name if svn_category is nil" do
      @article.mock_category = nil
      @article.path.should == 'article'
    end
  end
  
  describe "#path=" do
    before(:each) do
      @article = MockCategorizedArticle.new(:svn_name => 'article')
      @category = MockCategory.create(:svn_name => 'cat/path')
      @article.mock_category = @category
    end
    
    it "should move instance to a different category" do
      new_cat = MockCategory.create(:svn_name => 'cat/new')
      @article.path = "cat/new/article"
      @article.mock_category.should == new_cat
    end
    
    it "should update @svn_name" do
      @article.path = "cat/path/article2"
      @article.svn_name.should == 'article2'
    end
    
    it "should remove any category if only one path level" do
      MockCategory.should_not_receive(:get_or_create)
      @article.path = "article"
      @article.mock_category.should be_nil
      @article.path.should == 'article'
    end
    
    it "should ignore leading slash" do
      new_cat = MockCategory.create(:svn_name => 'cat/new')
      MockCategory.should_receive(:get_or_create).with('cat/new')
      @article.path = "//cat/new/article"
    end
    
  end
  
  describe ".get" do
    it "should get an instance if possible" do
      MockCategorizedArticle.should_receive(:get_by_path).
        with('path/to/name').
        and_return(1)
      
      MockCategorizedArticle.get('path/to/name', true) == 1
    end
    
    it "should try to get an instance of parent if needed (and get_parent is true)" do
      MockCategorizedArticle.should_receive(:get_by_path).
        with('path/to/name').
        and_return(nil)
      
      MockCategory.should_receive(:get_by_path).with('path/to/name').and_return(2)
      MockCategorizedArticle.get('path/to/name', true) == 2
    end

    it "should not try to get an instance of parent by default" do
      MockCategorizedArticle.should_receive(:get_by_path).
        with('path/to/name').
        and_return(nil)
      
      MockCategory.should_not_receive(:get_by_path)
      
      MockCategorizedArticle.get('path/to/name').should be_nil
    end
    
  end
  
  describe ".get_by_path" do
    it "should scope by category" do
      category = mock(MockCategory)
      
      MockCategory.should_receive(:first).
        with(:svn_name => 'path/to').
        and_return(category)
      
      category.should_receive(:id).and_return(3)
      
      MockCategorizedArticle.should_receive(:first).
        with(:svn_name => 'name', :mock_category_id => 3).
        and_return(nil)
        
      MockCategorizedArticle.get_by_path('path/to/name')
    end
  end
  
end