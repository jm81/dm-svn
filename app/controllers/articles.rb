class Articles < Application
  # provides :xml, :yaml, :js

  def index
    @articles = Article.published
    display @articles
  end

  def show
    @article = Article.get(params[:id])
    raise NotFound unless @article
    display @article
  end
  
end
