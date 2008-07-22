require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "..", "lib", "filters.rb" )

describe Filters do
  describe "#process" do
    before(:each) do
      @filter_one = mock("Filter 1")
      @filter_two = mock("Filter 2")
      @processor_one, @processor_two = mock("Processor 1"), mock("Processor 2")
      @processed_one, @processed_two = mock("Processed 1"), mock("Processed 2")
    end
    
    it "should process through each filter" do
      Filters.should_receive(:get_filter).with("FilterOne").and_return(@filter_one)
      @filter_one.should_receive(:new).with("content").and_return(@processor_one)
      @processor_one.should_receive(:to_html).and_return(@processed_one)
      Filters.should_receive(:get_filter).with(" FilterTwo").and_return(@filter_two)
      @filter_two.should_receive(:new).with(@processed_one).and_return(@processor_two)
      @processor_two.should_receive(:to_html).and_return(@processed_two)
      Filters.process("FilterOne; FilterTwo", "content").should == @processed_two
    end
  end

  describe "#get_filter" do
    it "should return nil if name not found in AVAILABLE_FILTERS" do
      Filters.get_filter("neverafilter").should be_nil
    end
    
    it "should return a filter if it's constant is defined" do
      red_cloth = mock('RedCloth')
      Object.should_receive(:const_defined?).with('RedCloth').and_return(true)
      Object.should_receive(:const_get).with('RedCloth').and_return(red_cloth)
      Filters.get_filter("Textile").should be(red_cloth)
    end
    
    it "should attempt to require an undefined filter" do
      red_cloth = mock('RedCloth')
      Object.should_receive(:const_defined?).with('RedCloth').and_return(false)
      Filters.should_receive(:require).with('redcloth').and_return(true)
      Object.should_receive(:const_get).with('RedCloth').and_return(red_cloth)
      Filters.get_filter("Textile").should be(red_cloth)
    end
  end
end
