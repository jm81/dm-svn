require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Wistle::Svn::Sync do
  describe "#run" do
    before(:all) do
      MockSyncModel.auto_migrate!
      @repos_uri = load_svn_fixture('articles_comments')
    end
    
    before(:each) do
      MockSyncModel.all.each { |m| m.destroy }
      Wistle::Model.all.each { |m| m.destroy }
      @ws_model = Wistle::Model.create(:name => 'MockSyncModel', :revision => 0)
      @ws_model.config = Wistle::Config.new
      @ws_model.config.uri = @repos_uri
      @sync = Wistle::Svn::Sync.new(@ws_model)
    end
    
    # This is a generic "it should just work" test
    it "should update database" do
      @sync.run
      MockSyncModel.count.should == 4
      
      comp = MockSyncModel.first(:svn_name => "computations")
      comp.body.should == 'Computers do not like salsa very much.'
      comp.svn_updated_rev.to_i.should == 7
      comp.svn_created_rev.to_i.should == 7
      
      phil = MockSyncModel.first(:svn_name => "philosophy")
      phil.svn_updated_rev.to_i.should == 2
      phil.svn_created_rev.to_i.should == 2
  
      pub  = MockSyncModel.first(:svn_name => "just_published")
      published_time = Time.parse(pub.published_at.strftime("%Y-%m-%d %H:%M:%S"))
      published_time.should be_close(Time.now - 3600, 100)
      pub.svn_created_by.should == "author"
      pub.title.should == "Private Thoughts"
      pub.svn_updated_rev.to_i.should == 7
      pub.svn_created_rev.to_i.should == 3
      
      MockSyncModel.first(:svn_name => "computers.txt").should be_nil
    end
    
    it "should update Wistle::Model entry" do
      @sync.run
      Wistle::Model.get(@ws_model.id).revision.should == 9
    end
  
    it "should return false if already at the youngest revision" do
      @sync.run.should be_true
      @ws_model = Wistle::Model.get(@ws_model.id)
      @ws_model.config = Wistle::Config.new
      @ws_model.config.uri = @repos_uri
      @sync = Wistle::Svn::Sync.new(@ws_model)
      @sync.run.should be_false
    end
  end
  
  describe "#run (categorized)" do
    before(:all) do
      MockCategory.auto_migrate!
      MockCategorizedArticle.auto_migrate!
      @repos_uri = load_svn_fixture('articles_comments')[0..-10]
    end
    
    before(:each) do
      MockCategory.all.each { |m| m.destroy }
      MockCategorizedArticle.all.each { |m| m.destroy }
      Wistle::Model.all.each { |m| m.destroy }
      @ws_model = Wistle::Model.create(:name => 'MockCategorizedArticle', :revision => 0)
      @ws_model.config = Wistle::Config.new
      @ws_model.config.uri = @repos_uri
      @sync = Wistle::Svn::Sync.new(@ws_model)
    end
    
    it "should update database, when categorized" do
      @sync.run
      
      MockCategory.count.should == 2
      MockCategorizedArticle.count.should == 6
      
      comp = MockCategorizedArticle.first(:svn_name => "computations")
      comp.body.should == 'Computers do not like salsa very much.'
      comp.svn_updated_rev.to_i.should == 7
      comp.svn_created_rev.to_i.should == 7
      
      phil = MockCategorizedArticle.first(:svn_name => "philosophy")
      phil.svn_updated_rev.to_i.should == 2
      phil.svn_created_rev.to_i.should == 2
      
      MockCategorizedArticle.first(:svn_name => "computers.txt").should be_nil
      
      articles = MockCategory.first(:svn_name => "articles")
      articles.mock_categorized_articles.length.should == 4
      comp.mock_category.id.should == articles.id
      articles.title.should == "Lots of Articles"
      
      comments = MockCategory.first(:svn_name => "comments")
      comments.mock_categorized_articles.length.should == 2
    end

  end
    
end
