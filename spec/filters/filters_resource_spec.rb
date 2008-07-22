require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "..", "lib", "filters.rb" )

class MockContent
  include DataMapper::Resource
  include Filters::Resource
  
  property :html, Text
  property :filters, String
end

describe Filters::Resource do
  describe ".property" do
    before(:each) do
      @model = MockContent
      @props = @model.properties
    end
        
    it "should add :to property if not defined" do
      @model.property(:body, String, :filter => {:to => :html2, :with => "Markdown"})
      MockContent.properties['html2'].should be_kind_of(DataMapper::Property)
    end

    it "should not add :with property if not defined" do
      @model.property(:body, String, :filter => {:to => :html, :with => :filters2})
      MockContent.properties['filters2'].should be_kind_of(DataMapper::Property)
    end
  end
end