require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Wistle::Svn::Node do
  before(:all) do
    @repos_uri = load_svn_fixture('articles_comments')
    
    Wistle::Model.all.each { |m| m.destroy }
    @ws_model = Wistle::Model.create(:name => 'MockSyncModel', :revision => 0)
    @ws_model.config = Wistle::Config.new
    @ws_model.config.uri = @repos_uri
    @sync = Wistle::Svn::Sync.new(@ws_model)
    @sync.__send__(:connect, @repos_uri)
    
    @cs   = @sync.changesets[1] # revision 2
    @cs3  = @sync.changesets[2] # revision 9
    @cs9  = @sync.changesets[7] # revision 9
    @dir  = Wistle::Svn::Node.new(@cs, "/articles")
    @file = Wistle::Svn::Node.new(@cs3, "/articles/unpublished.txt")
  end
  
  after(:all) do
    SvnFixture::Repository.destroy_all
  end
  
  it "should get short_path" do
    @file.short_path.should == "unpublished"
  end
  
  it "should check if file" do
    @dir.file?.should be_false
    @file.file?.should be_true
  end
  
  it "should check if directory" do
    @dir.directory?.should be_true
    @file.directory?.should be_false
  end
  
  it "should get body" do
    @dir.body.should be_nil
    @file.body.should == "See, it's not published.\nYou can't read it."
  end
  
  it "should remove yaml from body" do
    Wistle::Svn::Node.new(@cs9, "/articles/turtle.txt").body.should == 'Hi, turtle.'
  end
  
  describe "#properties" do
    it "should get properties from svn properties" do
      @dir.properties.should == 
        {
          'svn_updated_at' => @dir.date,
          'svn_updated_by' => @dir.author,
          'svn_updated_rev' => @dir.revision,
          'title' => 'Articles'
        } 
        
      @file.properties.should == 
        {
          'svn_updated_at' => @file.date,
          'svn_updated_by' => @file.author,
          'svn_updated_rev' => @file.revision,
          'title' => 'Private Thoughts'
        }
        
    end
    
    it "should get properties from yaml properties" do       
      dir9 = Wistle::Svn::Node.new(@cs9, "/articles")
      dir9.properties.should ==
        {
          'svn_updated_at' => dir9.date,
          'svn_updated_by' => dir9.author,
          'svn_updated_rev' => dir9.revision,
          'title' => 'Lots of Articles',
          'random_number' => 7
        }

      file9 = Wistle::Svn::Node.new(@cs9, "/articles/turtle.txt")
      file9.properties.should == 
        {
          'svn_updated_at' => file9.date,
          'svn_updated_by' => file9.author,
          'svn_updated_rev' => file9.revision,
          'title' => 'Turtle',
          'random_number' => 2
        }

    end
  end
  
  describe "variables from changeset" do
    before(:each) do
      @cs = mock(Wistle::Svn::Changeset)
      @node = Wistle::Svn::Node.new(@cs, 'path')
    end
    
    it "should get revision" do
      @cs.should_receive(:revision).and_return(2)
      @node.revision.should == 2
    end
    
    it "should get author" do
      @cs.should_receive(:author).and_return('jmorgan')
      @node.author.should == 'jmorgan'
    end
    
    it "should get date" do
      @cs.should_receive(:date).and_return('2008-05-10')
      @node.date.should == '2008-05-10'
    end
    
    it "should get repos" do
      @cs.should_receive(:repos).and_return(:repos)
      @node.repos.should == :repos
    end
    
    it "should get config" do
      @cs.should_receive(:config).and_return(:config)
      @node.config.should == :config
    end
  end
  
end