require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe SiteSvn do
  before(:all) do
    clean Site, Category, Article
    @fiction_uri = load_svn_fixture('fiction_site')
    @news_uri = load_svn_fixture('news_site')
    
    @fiction_site = Site.create(:name => "fiction", :contents_uri => @fiction_uri)
    @news_site = Site.create(:name => "news", :contents_uri => @news_uri)
    
    Site.sync_all
    
    @fiction_site = Site.get(@fiction_site.id)
    @news_site = Site.get(@news_site.id)
  end
  
  describe "(fiction)" do
    it "should be at revision 5" do
      @fiction_site.contents_revision.should == 5
    end
    
    it "should have 3 articles" do
      @fiction_site.articles.should have(3).members
    end
    
    it "should have 2 published article" do
      @fiction_site.published_articles.should have(2).members
      @fiction_site.published_articles[1].path.should == "scifi/alien/first"
      @fiction_site.published_articles[0].path.should == "scifi/spaceships"
    end
    
    it "should have 4 categories" do
      @fiction_site.categories.should have(4).members
      Category.get(@fiction_site, 'scifi').published?.should be_true
      Category.get(@fiction_site, 'scifi').published_articles.should have(2).members
      Category.get(@fiction_site, 'scifi/alien').published?.should be_true
      Category.get(@fiction_site, 'scifi/alien').published_articles.should have(1).member
      
      Category.get(@fiction_site, 'fantasy').published?.should be_false
      Category.get(@fiction_site, 'fantasy').published_articles.should have(0).members
      Category.get(@fiction_site, 'fantasy').articles[0].path.should == "fantasy/knights"
      
      Category.get(@fiction_site, 'western').published?.should be_false
      Category.get(@fiction_site, 'western').published_articles.should have(0).members
      Category.get(@fiction_site, 'western').articles.should have(0).members
    end
    
    it "should have 3 top-level categories" do
      @fiction_site.top_level_categories.should have(3).members
    end
    
    it "should have assigned category names" do
      Category.get(@fiction_site, 'scifi').name.should == "Science Fiction"
      Category.get(@fiction_site, 'scifi/alien').name.should == "Alien Stories"
      Category.get(@fiction_site, 'western').name.should == "Western"
    end
  end
  
  describe "(news)" do
    it "should be at revision 3" do
      @news_site.contents_revision.should == 3
    end
    
    it "should have 2 articles" do
      @news_site.articles.should have(2).members
    end
    
    it "should have 2 published article" do
      @news_site.published_articles.should have(2).members
      @news_site.published_articles[1].path.should == "sports/football"
      @news_site.published_articles[0].path.should == "politics/election"
    end
    
    it "should have 2 categories" do
      @news_site.categories.should have(2).members
      Category.get(@news_site, 'politics').published?.should be_true
      Category.get(@news_site, 'politics').published_articles[0].path.should == "politics/election"
      
      Category.get(@news_site, 'sports').published?.should be_true
      Category.get(@news_site, 'sports').published_articles[0].path.should == "sports/football"
    end
    
    it "should have 2 level categories" do
      @news_site.top_level_categories.should have(2).members
    end
  end
end
