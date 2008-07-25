class Articles < Application
  # provides :xml, :yaml, :js

  def index
    @articles = Article.published(:site_id => @site.id)
    display @articles
  end

  def show
    @article = Article.first(:id => params[:id], :site_id => @site.id)
    raise NotFound unless @article
    display @article
  end
  
end
