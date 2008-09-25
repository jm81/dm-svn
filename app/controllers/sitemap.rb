class Sitemap < Application
  provides :xml
  
  def index
    @articles = @site.published_articles
    @categories = @site.categories
    @tags = @site.tags
    @site_updated_at = @site.articles.max(:updated_at)
    @domain = "http://#{request.host}/"

    headers["Last-Modified"] = Time.parse(@site_updated_at.to_s).httpdate
    render
  end
end
