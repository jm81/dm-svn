require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "..", "lib", "filters", "linebreaker.rb" )

describe Linebreaker do

  it "should convert single line breaks to <br> tags" do
    Linebreaker.new("abc\n\ndef\nghi").to_html.should ==
      "abc\n\ndef<br />\nghi"
  end

end