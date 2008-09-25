class Articles < Application
  provides :xml
  include Merb::PaginationHelper
  
  def index
    by_date
  end
  
  def by_tag
    @articles = @site.articles_tagged(
      params[:tag], :page => params[:page], :limit => @site.per_page
    )
    
    display @articles, :index
  end
  
  # Also the default route
  def by_date
    @articles = @site.published_articles({
        :page => params[:page], :limit => @site.per_page,
        :year => params[:year], :month => params[:month], :day => params[:day]
    })
    
    display @articles, :index
  end

  def by_path
    obj = Article.get(@site, params[:path], true, true)
    
    if obj.nil?
      raise NotFound
    elsif obj.is_a? Article
      @article = obj
      display @article, :show
    else
      @articles = obj.published_articles(:page => params[:page], :limit => @site.per_page)
      display @articles, :index
    end
  end

  def show
    @article = @site.articles.get_published(params[:id])
    
    raise NotFound unless @article
    display @article
  end
  
  def search
    render
  end
  
  def sync
    @site.sync
    render "sync complete"
  end

  def sync_all
    Site.sync_all(params[:force_export])
    render "sync_all complete"
  end
end
