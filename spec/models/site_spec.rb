require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Site do
  before(:each) do
    Site.all.each {|s| s.destroy}
    @site = Site.new(:name => "sample")
  end
  
  it "should have many Articles" do
    @site.articles.should be_kind_of(DataMapper::Associations::OneToMany::Proxy)
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
  
  describe ".find_domain" do
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
  
  describe 'categories' do
    def article(path)
      Article.create(:path => path, :site_id => @site.id, :published_at => Time.now - 3600)
    end
  
    before(:each) do
      @site.save
      Article.all.each { |a| a.destroy }
      article('general/first')
      article('general/second')
      article('general/subfolder/another')
      article('computing/first')
      Article.create(:path => 'general/othersite', :site_id => @site.id + 1)
      Article.create(:path => 'different/othersite', :site_id => @site.id + 1)
    end
    
    it "should returns categories Array" do
      @site.categories.should == ['computing', 'general']
    end
    
    it "should find published Articles by category" do
      articles = @site.published_by_category('general')
      articles.length.should == 3
      articles = @site.published_by_category(nil)
      articles.length.should == 4
    end
  end
end