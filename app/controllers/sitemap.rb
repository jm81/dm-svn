class Sitemap < Application
  provides :xml, :txt
  
  def index
    @articles = @site.published_articles
    @categories = @site.categories
    @tags = @site.tags
    @site_updated_at = @site.articles.max(:updated_at)
    @domain = "http://#{request.host}/"

    headers["Last-Modified"] = Time.parse(@site_updated_at.to_s).httpdate
    render
  end
  
  def robots
    @domain = "http://#{request.host}/"
    render
  end
end
