require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "..", "lib", "wistle.rb" )

describe Wistle::Config do
  before(:each) do
    @c = Wistle::Config.new
  end
  
  it "should initialize @body_property to 'body'" do
    @c.body_property.should == 'body'
  end

  it "should modify @body_property" do
    @c.body_property = 'contents'
    @c.body_property.should == 'contents'
  end
end
