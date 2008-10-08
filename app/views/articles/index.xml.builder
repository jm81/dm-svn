domain = "http://#{request.host}/"

xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  
  xml.title @site.name
  xml.link(:href => domain, :rel => 'alternate', :hreflang => 'en-US')
  xml.link(:href => (domain + "articles.xml"), :rel => 'self', :hreflang => 'en-US')
  xml.updated @site.articles.max(:updated_at).to_s
  xml.id domain
  xml.generator "Wistle", {:uri => "http://code.google.com/p/wistle"}
  
  @articles.each do |article|
    xml.entry do
      xml.title article.title
      xml.updated [article.svn_updated_at, article.published_at].min.to_s
      
      xml.author do
        xml.name article.svn_created_by
      end
      
      xml.content(:type => 'xhtml', 'xml:lang' => 'en-US') do
        xml.div(:xmlns => "http://www.w3.org/1999/xhtml", 'xmlns:fg' => "http://fromgenesis.org") do |x|
          x << article.html
        end
      end
      
      xml.id(domain + article.path)
      xml.link(:href => (domain + article.path), :rel => 'alternate', :hreflang => 'en-US')
      xml.category(:term => article.category.name)
      xml.published article.published_at.to_s
      
    end
  end
end
