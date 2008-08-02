require 'rexml/document'
require 'open-uri'

class BibleML

  VERSION_IDS = {
    'cev' => 46,
    'niv' => 31,
    'nasb' => 49,
    'message' => 65,
    'amp' => 45,
    'nlt' => 51,
    '21st century kjv' => 48,
    'asv' => 8,
    'darby' => 16,
    'douay-rheims' => 63,
    'esv' => 47,
    'holman' => 77,
    'kjv' => 9,
    'ncv' => 78,
    'nkjv' => 50,
    'new life' => 74,
    'wycliffe' => 53,
    "young" => 15
  }

  def initialize(input)
    @xml = REXML::Document.new("<fg:body>#{input}</fg:body>")
  end
  
  def to_html
    self.
      primary_passage.
      strip_comments.
      block_quotes.
      inline_quotes.
      wikipedia_links.
      to_s
  end
  
  # Convert fg:pp tags to Primary Passage links
  # and set primary passage book and chapter from
  # last fg:pp tag.
  def primary_passage
    @xml.elements.each("//fg:pp") do | pp_el |
      ref = pp_el.attributes['p']
      ref_link = REXML::Element.new("a")
      ref_link.add_attribute('href', bg_link(ref))
      ref_link.text = "Read #{ref}"
      pp_el.parent.insert_after(pp_el, ref_link)

      marker = REXML::Text.new(" |\n")
      pp_el.parent.insert_after(ref_link, marker)

      chapter = pp_el.attributes['p'].split(":")[0]
      chapter_link = REXML::Element.new("a")
      chapter_link.add_attribute('href', bg_link(chapter))
      chapter_link.text = "Full Chapter"
      pp_el.parent.insert_after(marker, chapter_link)
      
      pp_el.parent.delete_element(pp_el)
      
      m = chapter.match(/(.*)\s(\d+)\Z/)
      @passage_book = m[1]
      @passage_chapter = m[2]
    end
    
    self
  end
  
  # Strip fg:cm tags
  def strip_comments
    @xml = REXML::Document.new(@xml.to_s.gsub(/\<\/?fg\:cm([^>]*)>/, ''))
    self
  end
  
  # Convent fg:bq tags to block quotes with reference
  def block_quotes
    @xml.elements.each("//fg:bq") do | bq_el |
      blockquote = REXML::Element.new("blockquote")
      
      if bq_el.has_elements? || bq_el.has_text? 
        bq_el.children.each do | child |
          blockquote << child
        end
      else
        blockquote << REXML::Text.new(get_passage(bq_el.attributes['p'], bq_el.attributes['v']))
      end
      
      blockquote << REXML::Text.new("\n")
      blockquote << REXML::Element.new("br")
      blockquote << REXML::Text.new("\n(")
      blockquote << reference_a(bq_el.attributes['p'], bq_el.attributes['v'])
      blockquote << REXML::Text.new(")\n")
      
      bq_el.parent.replace_child(bq_el, blockquote)
    end
    self
  end
  
  def wikipedia_links
    @xml.elements.each("//fg:wp") do | wp_el |
      a = REXML::Element.new("a")
      
      a.add_attribute('href', "http://en.wikipedia.org/wiki/#{wp_el.attributes['a']}")
      if wp_el.has_elements? || wp_el.has_text? 
        wp_el.children.each do | child |
          a << child
        end
      else
        a << REXML::Text.new(wp_el.attributes['a'])
      end
      
      wp_el.parent.replace_child(wp_el, a)
    end
    self
  end
  
  # Convent fg:iq tags to inline quotes with reference
  def inline_quotes
    @xml.elements.each("//fg:iq") do | iq_el |
      quote = REXML::Element.new("span")

      quote << REXML::Text.new("\"")
      
      if iq_el.has_elements? || iq_el.has_text? 
        iq_el.children.each do | child |
          quote << child
        end
      else
        quote << REXML::Text.new(get_passage(iq_el.attributes['p'], iq_el.attributes['v']))
      end
      
      quote << REXML::Text.new("\" (")
      quote << reference_a(iq_el.attributes['p'], iq_el.attributes['v'])
      quote << REXML::Text.new(")\n")
      
      iq_el.parent.replace_child(iq_el, quote)
    end
    self
  end
  
 def fill_missing_text
    @xml.elements.each("//fg:pp") do | pp_el |
      chapter = pp_el.attributes['p'].split(":")[0]
      m = chapter.match(/(.*)\s(\d+)\Z/)
      @passage_book = m[1]
      @passage_chapter = m[2]
    end

    @xml.elements.each("//fg:iq") do | q_el |
      unless q_el.has_elements? || q_el.has_text? 
        q_el << REXML::Text.new(get_passage(q_el.attributes['p'], q_el.attributes['v']))
      end
    end

    @xml.elements.each("//fg:bq") do | q_el |
      unless q_el.has_elements? || q_el.has_text?
        psg = get_passage(q_el.attributes['p'], q_el.attributes['v'])
        psg = wordwrap(" " + psg) + "\n"
        q_el << REXML::Text.new(psg)
      end
    end
    self
  end
  
  # Based on http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/10655
  def wordwrap(txt)
    txt.gsub(/\t/,"     ").
        gsub(/\"/,"&quot;").
        gsub(/\'/,"&apos;").
        gsub(/.{1,78}(?:\s|\Z)/){($& + 5.chr).
        gsub(/\n\005/,"\n  ").
        gsub(/\005/,"\n  ")}.
        gsub(/&quot;/, "\"").
        gsub(/&apos;/, "\'")
  end
  
  class << self
    def fill_missing_text(input)
      new(input).fill_missing_text.to_s
    end
  end
  
  def to_s
    @xml.to_s.gsub(/<\/?fg:body>/, '')
  end
  
  # Add book and chapter information to shorthand references
  def expand_reference(ref)
    ref.strip!
    if ref.match(/\A(\d+-?\d*)\Z/) # Just verse(s) given
      "#{@passage_book} #{@passage_chapter}:#{ref}"
    elsif ref.match(/\A(\d+):(\d+-?\d*)\Z/) # Just chapter and verse(s) given
      "#{@passage_book} #{ref}"
    else
      ref
    end
  end
  
  # Generate 'a' element for reference link
  def reference_a(ref, version = nil, label = nil)
    ref = expand_reference(ref)

    unless label
      label = ref
      label += ", #{version}" if version
    end
    
    ref_link = REXML::Element.new("a")
    ref_link.add_attribute('href', bg_link(ref, version))
    ref_link.text = label
    
    ref_link        
  end
     
  def bg_link(ref, version = nil)
    ref = expand_reference(ref)
    
    ln = "http://www.biblegateway.com/passage/?search=" + ref.downcase.gsub(/\s/, "%20")
    ln += ";&version=#{VERSION_IDS[version.downcase]};" if version
    ln
  end
  
  def get_passage(ref, version = "NASB")
    xhtml = open(bg_link(ref, version)) do |f|
      html = f.read.split('<div class="result-text-style-normal">')[1]
      html = html.split('</div>')[0]
      html = html.split('<strong>Cross references')[0]
      html = html.split('<strong>Footnotes:')[0]
              
      REXML::Document.new("<body>#{html}</body>")
    end

    xhtml.root.elements.delete_all("//h4")
    xhtml.root.elements.delete_all("//h5")
    xhtml.root.elements.delete_all("//span")
    xhtml.root.elements.delete_all("//sup")
    xhtml.root.elements.delete_all("//br")

    xhtml.to_s.gsub(/<\/?body>/, '').gsub(/<\/?p\/?>/, '').gsub('&nbsp;', ' ').squeeze(" ").gsub(/ \" /, ' "')
  end
end
