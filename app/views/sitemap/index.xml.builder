xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc(@domain)
    xml.priority 1.0
    xml.changefreq 'weekly'
    xml.lastmod @site_updated_at.strftime("%Y-%m-%d")
  end
    
  @articles.all.each do |article|
    xml.url do
      xml.loc(@domain + article.path)
      xml.priority 0.8
      xml.changefreq 'yearly'
      xml.lastmod article.svn_updated_at.strftime("%Y-%m-%d")
    end
  end
  
  @categories.each do |category|
    xml.url do
      xml.loc(@domain + "categories/" + category)
      xml.priority 0.3
      xml.changefreq 'monthly'
    end
  end
  
  @tags.each do |tag|
    xml.url do
      xml.loc(@domain + "tags/" + tag.name)
      xml.priority 0.1
      xml.changefreq 'monthly'
    end
  end
end
