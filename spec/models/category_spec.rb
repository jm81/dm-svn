require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Category do

  before(:all) do
    migrate Site, Category
  end

  before(:each) do
    # Setup a heirarchy:
    # /poetry
    # /prose
    #   /prose/essays
    #   /prose/stories
    
    clean Site, Category
    @site = setup_site
    @prose  = setup_category(@site, :svn_name => 'prose')
    @poetry = setup_category(@site, :svn_name => 'poetry', :name => 'Poems')
    @stories = setup_category(@site, :svn_name => 'stories', :name => 'Stories')
    @essays  = setup_category(@site, :svn_name => 'essays', :name => 'Essays')
    @stories.parent = @prose; @stories.save
    @essays.parent  = @prose; @essays.save
  end
  
  it "should be valid" do
    @prose.should be_valid
  end

  describe "#name" do
    it "should return a name" do
      @poetry.update_attributes(:name => "Poems")
      @poetry.name.should == "Poems"
    end
    
    it "should default to capitalized svn_name" do
      @poetry.update_attributes(:name => nil)
      @poetry.name.should == "Poetry"
      @poetry.update_attributes(:name => '')
      @poetry.name.should == "Poetry" 
    end
  end
  
  it "should have an optional parent" do
    @prose.parent.should be_nil
    @stories.parent.should be(@prose)
  end
  
  it "should have many children" do
    @prose.children.should == [@essays, @stories]
    @stories.children.should == []
  end
  
  it "should return a full path" do
    @prose.path.should == "prose"
    @stories.path.should == "prose/stories"
  end
  
  describe "path=" do
    it "should update svn_name" do
      @stories.path = "prose/story"
      @stories.save
      @stories.svn_name.should == "story"
      @stories.parent.should == @prose
    end
    
    it "should move to a different category" do
      @stories.path = "poetry/stories"
      @stories.save
      @stories.svn_name.should == "stories"
      @stories.parent.should == @poetry
      @prose.children.should have(1).member
    end
    
    it "should create a needed parent category" do
      cat_count = Category.count
      @stories.path = "fiction/stories"
      @stories.save
      @stories.svn_name.should == "stories"
      @stories.parent.svn_name.should == "fiction"
      @stories.parent.should be_valid
      @stories.path.should == "fiction/stories"
      
      Category.count.should == cat_count + 1
    end
    
  end

  describe ".include SvnExtension" do
    it "should get by path" do
      Category.get(@site, "prose").should == @prose
      Category.get(@site, "prose/stories").should == @stories
      Category.get(@site, "prose/none").should be_nil
    end
  end
  
  describe "#published_articles" do
    before(:each) do
      clean Article
      @red = setup_article(@stories, :svn_name => 'red-riding-hood', :published_at => (Time.now - 3600))
      @grindle = setup_article(@stories, :svn_name => 'grindle', :published_at => (Time.now + 3600))
      @beowulf = setup_article(@stories, :svn_name => 'beowulf')
      
      @politics = setup_article(@essays, :svn_name => "politics", :published_at => (Time.now - 2800))
    end
    
    it "should get published articles" do
      c = setup_category(@site, :svn_name => 'stuff', :name => 'Stuff')
      c.published_articles.should == []
      
      @prose.published_articles.should == [@politics, @red]
      @stories.published_articles.should == [@red]
      @essays.published_articles.should == [@politics]
      
      @site.published_articles.should == [@politics, @red]
    end
  end
  
  describe "#published?" do
    before(:each) do
      clean Article
      @red = setup_article(@stories, :svn_name => 'red-riding-hood', :published_at => (Time.now - 3600))
      @politics = setup_article(@essays, :svn_name => "politics", :published_at => (Time.now + 3600))
    end
    
    it "should be true if any articles have been published" do
      @stories.published?.should be_true
    end
    
    it "should be false if no articles have been published" do
      @essays.published?.should be_false
    end
  end
  
end