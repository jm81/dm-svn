require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "..", "lib", "filters", "bible_ml.rb" )

describe BibleML do

  it "should convert a fg:bq element to a block quote" do
    BibleML.new('<p>1</p><fg:bq p="Exodus 5:1-5" v="ESV">quote <span>hi</span></fg:bq><p>2</p>').
      block_quotes.
      to_s.should ==
      "<p>1</p><blockquote>quote <span>hi</span>\n<br/>\n" +
      "(<a href='http://www.biblegateway.com/passage/?search=exodus%205:1-5;&amp;version=47;'>Exodus 5:1-5, ESV</a>)" +
      "\n</blockquote><p>2</p>"
  end
    
  it "should fill in text of an empty fg:bq element" do
    BibleML.new('<fg:bq p="Exodus 5:2-3" v="CEV" />').
      block_quotes.
      to_s.should ==
      "<blockquote>\n &quot;Who is this LORD and why should I obey him?&quot; the king replied. &quot;I refuse to let you and your people go!&quot; " +
      "They answered, &quot;The LORD God of the Hebrews, has appeared to us. Please let us walk three days into the desert " +
      "where we can offer sacrifices to him. If you don&apos;t, he may strike us down with terrible troubles or with war.&quot; \n" +
      "<br/>\n" +
      "(<a href='http://www.biblegateway.com/passage/?search=exodus%205:2-3;&amp;version=46;'>Exodus 5:2-3, CEV</a>)" +
      "\n</blockquote>"
  end

  it "should assume book and chapter based on bg:pp if ommitted" do
    convertor = BibleML.new('<fg:pp p="Exodus 5:1-5" />').primary_passage
    convertor.expand_reference("7").should == "Exodus 5:7"
    convertor.expand_reference("7-10").should == "Exodus 5:7-10"
    convertor.expand_reference("6:7").should == "Exodus 6:7"
    convertor.expand_reference("6:7-10").should == "Exodus 6:7-10"
    convertor.expand_reference("John 6:7").should == "John 6:7"
    convertor.expand_reference("John 6:7-10").should == "John 6:7-10"
  end

  it "should convert a fg:iq element to an inline quote" do
    BibleML.new('<p>this is a <fg:iq p="1 Peter 1:2" v="Young">inline quote</fg:iq></p>').
      inline_quotes.
      to_s.should ==
      "<p>this is a <span>&quot;inline quote&quot; " +
      "(<a href='http://www.biblegateway.com/passage/?search=1%20peter%201:2;&amp;version=15;'>1 Peter 1:2, Young</a>)" +
      "\n</span></p>"
  end
  
  it "should fill in text of an empty fg:iq element" do
    BibleML.new('<p><fg:iq p="1 Peter 1:2" v="Young" /></p>').
      inline_quotes.
      to_s.should ==
      "<p><span>&quot;\n according to a foreknowledge of God the Father, in sanctification of the Spirit, " +
      "to obedience and sprinkling of the blood of Jesus Christ: Grace to you and peace be multiplied! &quot; " +
      "(<a href='http://www.biblegateway.com/passage/?search=1%20peter%201:2;&amp;version=15;'>1 Peter 1:2, Young</a>)" +
      "\n</span></p>"
  end
  
  it "should strip fg:cm tags" do
    BibleML.new('test <fg:cm p="Genesis 11:10-11">comment</fg:cm> test2').
      strip_comments.
      to_s.should ==
      "test comment test2"
  end
  
  it "should convert fg:pp tag to Primary Passage links" do
    BibleML.new('<fg:pp p="Exodus 5:1-5" />').
      primary_passage.
      to_s.should ==
      "<a href='http://www.biblegateway.com/passage/?search=exodus%205:1-5'>Read Exodus 5:1-5</a> |\n" +
      "<a href='http://www.biblegateway.com/passage/?search=exodus%205'>Full Chapter</a>"
  end
  
  it "should create link from reference with verses" do
    BibleML.new('').bg_link("Genesis 1:10").should ==
      "http://www.biblegateway.com/passage/?search=genesis%201:10"
  end
  
  it "should create link from reference without verses" do
    BibleML.new('').bg_link("Genesis 1").should ==
      "http://www.biblegateway.com/passage/?search=genesis%201"
  end
  
  it "should convert version names to biblegateway.com ids" do
    BibleML::VERSION_IDS['niv'].should == 31
    BibleML::VERSION_IDS['cev'].should == 46
  end
  
  it "should convert an fg:wp element to a wikipedia link" do
    BibleML.new('<fg:wp a="Bible">the Bible</fg:wp>').
      wikipedia_links.
      to_s.should ==
      "<a href='http://en.wikipedia.org/wiki/Bible'>the Bible</a>"
  end
  
  it "should convert fixture (full document)" do
    input  = File.read(File.dirname(__FILE__) + "/fixtures/gen11/input.xml")
    output = File.read(File.dirname(__FILE__) + "/fixtures/gen11/output.xml")
    BibleML.new(input).to_html.should == output
  end

  it "should convert only missing text" do
    BibleML::fill_missing_text('<p><fg:iq p="1 Peter 1:2" v="Young" /></p>').
      should ==
      "<p><fg:iq v='Young' p='1 Peter 1:2'>\n according to a foreknowledge of God the Father, in sanctification of the Spirit, " +
      "to obedience and sprinkling of the blood of Jesus Christ: Grace to you and peace be multiplied! </fg:iq></p>"
  end
end