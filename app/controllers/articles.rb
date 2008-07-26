class Articles < Application
  # provides :xml, :yaml, :js

  def index
    @articles = @site.published_by_category(params[:category])
    display @articles
  end

  def show
    if params[:path]
      @article = Article.first(:path => params[:path], :site_id => @site.id)
    else
      @article = Article.first(:id => params[:id], :site_id => @site.id)
    end
    
    raise NotFound unless @article
    display @article
  end
  
end
