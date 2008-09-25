require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Article do
  
  before(:each) do
    migrate Site, Category, Article, Comment, Tag, Tagging
    clean Site, Category, Article, Comment, Tag, Tagging
    
    @site = Site.create(:name => 'site')
    @category = @site.categories.create(:name => "Category")
    @article = @category.articles.create(:title => "First Post", :body => "Howdy Folks")
  end
    
  it "should have many comments" do
    @article2 = setup_article(@category)
    @article3 = setup_article(@category)
    5.times do |i|
      setup_comment(@article)
      setup_comment(@article2)
      setup_comment(@article3)
    end
    
    Article.get(@article.id).should have(5).comments
  end
  
  it "should have direct_comments" do
    5.times do |i|
      c = setup_comment(@article)
      if i > 2
        c.parent_id = 1
        c.save
      end
    end
    
    Article.get(@article.id).should have(5).comments
    Article.get(@article.id).should have(3).direct_comments
  end
  
  it "should filter body to html" do
    @article.body = "Howdy *folks*"
    @article.filters = "Markdown"
    @article.save
    @article.html.should == "<p>Howdy <em>folks</em></p>\n"
  end

  it "should filter body to html (with Textile)" do
    @article.body = "Howdy *folks* ^2^"
    @article.filters = "Textile"
    @article.save
    @article.html.should == "<p>Howdy <strong>folks</strong> <sup>2</sup></p>"
  end
  
  describe "#published_at" do
    it "should respond to #published?" do
      @article.published_at = nil
      @article.published?.should be_false
      
      @article.published_at = Time.now - 3600
      @article.published?.should be_true
      
      @article.published_at = nil
      @article.published?.should be_false
      
      @article.published_at = Time.now + 3600
      @article.published?.should be_false
    end

    it "should be set by #published=" do
      @article.published = false
      @article.published_at.should be_nil
      
      @article.published = true
      @article.published_at.should be_kind_of(DateTime)
      
      @article.published = false
      @article.published_at.should be_nil
      
      @article.published = '0'
      @article.published_at.should be_nil
    end
    
    # I managed to cause a problem with this at one point with my "Boolean
    # Timestamp" stuff. I don't remember the details, so I'm throwing in a test
    # to make myself feel better.
    it "should save #published_at nil" do
      @article.published_at = Time.now
      @article.save
      @article.reload_attributes(:published_at)
      @article.published?.should be_true

      @article.published_at = nil
      @article.save
      @article.reload_attributes(:published_at)
      @article.published?.should be_false      
    end
  end
  
  describe "#comments_allowed_at" do
    it "should respond to #comments_allowed?" do
      @article.comments_allowed_at = nil
      @article.comments_allowed?.should be_false
      
      @article.comments_allowed_at = Time.now
      @article.comments_allowed?.should be_true
      
      @article.comments_allowed_at = nil
      @article.comments_allowed?.should be_false      
    end

    it "should be set by #comments_allowed=" do
      @article.comments_allowed = false
      @article.comments_allowed_at.should be_nil
      
      @article.comments_allowed = true
      @article.comments_allowed_at.should be_kind_of(DateTime)
      
      @article.comments_allowed = false
      @article.comments_allowed_at.should be_nil
    end
  end
  
  it "should have many tags" do
    @article.taggings.count.should == 0
    @article.tags.length.should == 0
    @article.taggings.create(:tag => Tag.create(:name => 'Wilbur'))
    @article.taggings.create(:tag => Tag.create(:name => 'Charlotte'))
    @article.tags.count.should == 2
  end
  
  it "should set tags" do
    @article.taggings.count.should == 0
    @article.tags = "Charlotte; Wilbur"
    @article.taggings.count.should == 2

    @article.tags = "Aladdin"
    @article.taggings.count.should == 1
    @article.tags[0].name.should == "Aladdin"
  end
  
  it "should belong to a Site" do
    site = Site.create(:name => "newsite")
    article = setup_article(site)
    article.site.name.should == site.name
  end
  
end