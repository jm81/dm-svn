require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Articles do
  before(:each) do
    @site = mock(Site)
    Site.stub!(:by_domain).and_return(@site)
    @site.stub!(:name).and_return('stub_site')
    @site.stub!(:per_page).and_return(5)
  end
  
  describe "#by_date" do
    def do_get(params = {})
      dispatch_to(Articles, :index) do |controller| 
        controller.stub!(:display)
      end 
    end
    
    it "fetches published articles from site when no params" do 
      @site.should_receive(:published_articles).with(:page => nil, :limit => 5,
        :year => nil, :month => nil, :day => nil)
      do_get
    end 
  end 
 
end 