require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe DmSvn::Svn::Changeset do
  before(:all) do
    DmSvn::Model.auto_migrate!
  end
  
  describe "#short_path" do
    before(:each) do
      DmSvn::Model.all.each { |m| m.destroy }
      sync = mock('DmSvn::Svn::Sync')
      @config = DmSvn::Config.new
      @config.extension = nil
      @config.path_from_root = "/articles"
      sync.stub!(:config).and_return @config
      sync.stub!(:model).and_return nil
      sync.stub!(:repos).and_return nil
      
      @changeset = DmSvn::Svn::Changeset.new([], 1, '', Time.now, sync)
    end
    
    it "should remove 'leading path'" do
      @changeset.__send__(:short_path, "/articles/something").should == "something"
    end
    
    it "should remove extension if configured" do
      @config.extension = 'txt'
      @changeset.__send__(:short_path, "/articles/something.txt").should == "something"
    end

    it "should not remove other extensions" do
      @config.extension = 'txt'
      @changeset.__send__(:short_path, "/articles/something.jpg").should == "something.jpg"
    end

    it "should not remove extension if not configured" do
      @changeset.__send__(:short_path, "/articles/something.txt").should == "something.txt"
    end
  end
  
end
