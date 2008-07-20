require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "..", "lib", "wistle.rb" )

class MockSyncModel
  include DataMapper::Resource
  include Wistle::Svn
  
  property :id, Integer, :serial => true
  property :title, String
  property :body, Text, :body_property => true
  property :published_at, DateTime
  
end

describe Wistle::SvnSync do
  describe "#run" do
    before(:all) do
      MockSyncModel.auto_migrate!
      load(File.join(File.dirname(__FILE__), "fixtures", "articles_comments.rb" ))
      repos_path = File.join(File.dirname(__FILE__), "..", "..", "lib", "wistle", "tmp", "repo_articles_comments" )
      @repos_uri = "file://" + File.expand_path(repos_path) + "/articles"
    end
    
    before(:each) do
      MockSyncModel.all.each { |m| m.destroy }
      Wistle::Model.all.each { |m| m.destroy }
      @ws_model = Wistle::Model.create(:name => 'MockSyncModel', :revision => 0)
      @ws_model.config = Wistle::Config.new
      @ws_model.config.uri = @repos_uri
      @sync = Wistle::SvnSync.new(@ws_model)
    end
    
    # This is a generic "it should just work" test
    it "should update database" do
      @sync.run
      MockSyncModel.count.should == 3
      
      comp = MockSyncModel.first(:path => "computations")
      comp.body.should == 'Computers do not like salsa very much.'
      comp.svn_updated_rev.to_i.should == 7
      comp.svn_created_rev.to_i.should == 7
      
      phil = MockSyncModel.first(:path => "philosophy")
      phil.svn_updated_rev.to_i.should == 2
      phil.svn_created_rev.to_i.should == 2
  
      pub  = MockSyncModel.first(:path => "just_published")
      published_time = Time.parse(pub.published_at.strftime("%Y-%m-%d %H:%M:%S"))
      published_time.should be_close(Time.now - 3600, 100)
      pub.svn_created_by.should == "author"
      pub.title.should == "Private Thoughts"
      pub.svn_updated_rev.to_i.should == 7
      pub.svn_created_rev.to_i.should == 3
      
      MockSyncModel.first(:path => "computers.txt").should be_nil
    end
    
    it "should update Wistle::Model entry" do
      @sync.run
      @ws_model.revision.should == 8
    end
  
    it "should return false if already at the youngest revision" do
      @sync.run.should be_true
      @sync.run.should be_false
    end
  end
  
  describe "#short_path" do
    before(:each) do
      Wistle::Model.all.each { |m| m.destroy }
      @ws_model = Wistle::Model.create(:name => 'MockSyncModel', :revision => 0)
      @ws_model.config = Wistle::Config.new
      @ws_model.config.extension = nil
      @sync = Wistle::SvnSync.new(@ws_model)
      @sync.instance_variable_set("@path_from_root", "/articles")
    end
    
    it "should remove 'leading path'" do
      @sync.__send__(:short_path, "/articles/something").should == "something"
    end
    
    it "should remove extension if configured" do
      @ws_model.config.extension = 'txt'
      @sync.__send__(:short_path, "/articles/something.txt").should == "something"
    end

    it "should not remove other extensions" do
      @ws_model.config.extension = 'txt'
      @sync.__send__(:short_path, "/articles/something.jpg").should == "something.jpg"
    end

    it "should not remove extension if not configured" do
      @sync.__send__(:short_path, "/articles/something.txt").should == "something.txt"
    end
  end
  
end
