require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Site do
  before(:all) do
    migrate Site, Category, Article
  end
  
  before(:each) do
    clean Site, Category, Article
    
    @site = Site.create(:name => "sample")
    @category = @site.categories.create(:name => "First")
    @site.categories.create(:name => "Second")
    @site.categories.create(:name => "Third", :parent_id => @category.id)
  end
  
  it "should have many Categories" do
    @site.categories.should be_kind_of(DataMapper::Associations::OneToMany::Proxy)
    @site.categories.should have(3).members
    @category.site.should == @site
  end
  
  it "should distinguish top-level Categories" do
    @site.categories.should be_kind_of(DataMapper::Associations::OneToMany::Proxy)
    @site.top_level_categories.should have(2).members
  end
  
  it "should have many Articles" do
    a = @category.articles.create(:title => "Title", :body => "Contents")
    a.category.should == @category
    a.site.should == @site
    @site.articles.should be_kind_of(DataMapper::Associations::OneToMany::Proxy)
    @site.articles.should have(1).member
  end
  
  it "should alias contents_uri as uri" do
    @site.contents_uri = "svn://example.org/trunk"
    @site.uri.should == "svn://example.org/trunk"
  end

  it "should alias contents_revision as revision" do
    @site.contents_revision = 5
    @site.revision.should == 5
  end
  
  it "should alias contents_revision= as revision=" do
    @site.revision = 10
    @site.contents_revision.should == 10
  end

  it "should define 'body_property'" do
    @site.body_property.should == :body
  end
  
  describe "#name" do
    it "should be unique" do
      @site.should be_valid
      @site.save
      Site.new(:name => "sample").should_not be_valid
    end
  end
  
  describe ".by_domain" do
    before(:each) do
      Site.all.each {|s| s.destroy}
      Site.create(:name => "subdomain", :domain_regex => 'www\.example\.com')
      Site.create(:name => "domain", :domain_regex => 'example\.com')
      Site.create(:name => "no_subdomain", :domain_regex => '\Aexample\.org')
      Site.create(:name => "no_tld", :domain_regex => "example")
      Site.create(:name => "blank", :domain_regex => "")
    end
    
    it "should find 'subdomain' from www.example.com (longest match)" do
      Site.by_domain('www.example.com').id.should == Site.first(:name => 'subdomain').id
    end
    
    it "should find 'domain' from something.example.com (find by regex)" do
      Site.by_domain('something.example.com').id.should == Site.first(:name => 'domain').id
    end

    it "should find 'no_subdomain' from example.org (find by regex)" do
      Site.by_domain('example.org').id.should == Site.first(:name => 'no_subdomain').id
    end
    
    it "should find 'no_tld' from www.example.org (acknowledge regex anchor)" do
      Site.by_domain('www.example.org').id.should == Site.first(:name => 'no_tld').id
    end
    
    it "should find 'blank' from www.ruby-lang.org" do
      Site.by_domain('www.ruby-lang.org').id.should == Site.first(:name => 'blank').id
    end
    
  end
  
  it "should have many tags" do
    @category.articles.create.tags = "Chicken; Soup"
    @site.tags.count.should == 2
    
    other = setup_article
    other.tags = "Other; Chicken"
    @site.tags.count.should == 2
  end
  
  describe "#articles_tagged" do
    before(:each) do
      @soup_site  = Site.create(:name => "soup", :domain_regex => '1\.com')
      @chili_site = Site.create(:name => "chili", :domain_regex => '2\.com')
      
      a = setup_article(@soup_site, :published_at => (Time.now - 3600))
      a.tags = "Chicken"
      a.save
      a = setup_article(@soup_site, :published_at => (Time.now - 3600))
      a.tags = "Chicken; Soup"
      a.save
      
      @soup  = setup_article(@soup_site, :published_at => (Time.now - 3600))
      @soup.tags = "Tomato"
      @soup.save
      
      @chili = setup_article(@chili_site, :published_at => (Time.now - 3600))
      @chili.tags = "Tomato"
      @chili.save
    end

    it "should get articles_tagged" do
      @soup_site.articles_tagged("Chicken").length.should == 2
      @soup_site.articles_tagged("Tomato").should == [@soup]
      @chili_site.articles_tagged("Tomato").should == [@chili]
    end
    
    it "should not get unpublished articles" do
      @soup.update_attributes(:published_at => (Time.now + 3600))
      @soup_site.articles_tagged("Tomato").length.should == 0
    end
  
    it "should count_articles_tagged" do
      @soup_site.count_articles_tagged("Chicken").should == 2
      @soup_site.count_articles_tagged("Tomato").should == 1
      @chili_site.count_articles_tagged("Chicken").should == 0
      @chili_site.count_articles_tagged("Tomato").should == 1
    end
  end
  
  describe 'comments methods' do
    def article(path)
      c = setup_category(@site)
      c.path = "cat"
      c.save
      a = setup_article(c)
      a.update_attributes(:svn_name => path, :published_at => Time.now - 3600)
      a
    end
    
    def comment(article_id)
      article_id = article_id.id if article_id.kind_of?(Article)
      c = Comment.new
      c.author = "Author"
      c.body = "A comment on Article #{article_id}"
      c.article_id = article_id
      c.save
      return c
    end
    
    before(:each) do
      @site.save
      clean Article, Comment
      @articles = [article('first'), article('second')]
      @comments = [comment(@articles[0]), comment(@articles[1]), comment(@articles[0]), comment(@articles[1])]
    end
  
    it 'should store article paths for all comments' do
      @site.store_article_paths
      0.upto(3) do |i|
        @comments[i].reload
        @comments[i].stored_article_path.should == @articles[i % 2].path
      end
    end
    
    it 'should reassociate all comments' do
      @site.store_article_paths
      c = @site.reassociate_comments.should be(true)
      
      @comments.each do |c|
        c.update_attributes(:stored_article_path => 'cat/no_path')
      end
      @site.reassociate_comments.length.should == 4
    end
    
  end
  
    
  describe "#articles.get" do
    
    it "should scope by Site" do
      clean Site, Article
      s1 = Site.create(:name => 'first')
      a1 = setup_article(s1, :svn_name => 'path')
      s2 = Site.create(:name => 'second')
      a2 = setup_article(s2, :svn_name => 'path')
      
      a1.category.update_attributes(:svn_name => "cat")
      a2.category.update_attributes(:svn_name => "cat")
      
      Article.get(s1, 'cat/path').id.should == a1.id
      s1.articles.get('cat/path').id.should == a1.id
      s2.articles.get('cat/path').id.should == a2.id
      s1.articles.get('cat/no_path').should be_nil
    end
    
  end
  
  describe "#articles.get_published" do
    before(:each) do
      clean Site, Article
    end
    
    it "should scope by Site" do
      s1 = Site.create(:name => 'first')
      a1 = setup_article(s1, :svn_name => 'path', :published_at => (Time.now - 3600))
      s2 = Site.create(:name => 'second')
      a2 = setup_article(s2, :svn_name => 'path', :published_at => (Time.now - 3600))
      
      a1.category.update_attributes(:svn_name => "cat")
      a2.category.update_attributes(:svn_name => "cat")
      
      Article.get(s1, 'cat/path').should == a1
      s1.articles.get_published('cat/path').should == a1
      s2.articles.get_published('cat/path').should == a2
      s1.articles.get_published('cat/no_path').should be_nil
    end
    
    it "should only get published" do
      s1 = Site.create(:name => 'first')
      a1 = setup_article(s1, :svn_name => 'path', :published_at => (Time.now - 3600))
      a1.category.update_attributes(:svn_name => "cat")
      s1.articles.get_published('cat/path').id.should == a1.id
      
      # unpublished
      a1.update_attributes(:published_at => nil)
      s1.articles.get_published('cat/path').should be_nil
      
      # published in the future
      a1.update_attributes(:published_at => (Time.now + 3600))
      s1.articles.get_published('cat/path').should be_nil
    end
    
  end
  
  describe "#published_articles" do
    before(:each) do
      @prose  = setup_category(@site, :svn_name => 'prose')
      @poetry = setup_category(@site, :svn_name => 'poetry', :name => 'Poems')
      @stories = setup_category(@site, :svn_name => 'stories', :name => 'Stories')
      @essays  = setup_category(@site, :svn_name => 'essays', :name => 'Essays')
      @stories.parent = @prose; @stories.save
      @essays.parent  = @prose; @essays.save
      
      @red = setup_article(@stories, :svn_name => 'red-riding-hood', :published_at => (Time.now - 3600))
      @grindle = setup_article(@stories, :svn_name => 'grindle', :published_at => (Time.now + 3600))
      @beowulf = setup_article(@stories, :svn_name => 'beowulf')
      
      @politics = setup_article(@essays, :svn_name => "politics", :published_at => (Time.now - 2800))
    end
    
    it "should get published articles" do
      @site.published_articles.should == [@politics, @red]
    end
    
    it "should scope by site" do
      new_article = setup_article(nil, :svn_name => 'red-riding-hood', :published_at => (Time.now - 3600))
      new_article.category.update_attributes(:svn_name => 'cat')
      @site.published_articles.should == [@politics, @red]
      new_article.site.published_articles.should == [new_article]
    end
    
    it "should get all for a year" do
      @green  = setup_article(@stories, :svn_name => 'green-riding-hood', :published_at => '1999-08-10')
      @yellow = setup_article(@stories, :svn_name => 'yellow-riding-hood', :published_at => '1999-06-10')
      @blue   = setup_article(@stories, :svn_name => 'red-riding-hood', :published_at => '1998-08-10')
      
      @site.published_articles(:year => 1999).should == [@green, @yellow]
      @site.published_articles(:year => 1998).should == [@blue]
      @site.published_articles(:year => 1997).should == []
    end
    
    it "should get all for a month" do
      @green  = setup_article(@stories, :svn_name => 'green-riding-hood', :published_at => '1999-08-10')
      @yellow = setup_article(@stories, :svn_name => 'yellow-riding-hood', :published_at => '1999-08-05')
      @blue   = setup_article(@stories, :svn_name => 'red-riding-hood', :published_at => '1999-07-10')
      
      @site.published_articles(:year => 1999, :month => 8).should == [@green, @yellow]
      @site.published_articles(:year => 1999, :month => 7).should == [@blue]
      @site.published_articles(:year => 1999, :month => 6).should == []
    end
    
    it "should get all for a day" do
      @green  = setup_article(@stories, :svn_name => 'green-riding-hood', :published_at => '1999-08-10')
      @yellow = setup_article(@stories, :svn_name => 'yellow-riding-hood', :published_at => '1999-08-10')
      @blue   = setup_article(@stories, :svn_name => 'red-riding-hood', :published_at => '1999-08-05')
      
      @site.published_articles(:year => 1999, :month => 8, :day => 10).should == [@green, @yellow]
      @site.published_articles(:year => 1999, :month => 8, :day => 5).should == [@blue]
      @site.published_articles(:year => 1999, :month => 8, :day => 15).should == []
    end
  end

end