class Articles < Application
  provides :xml
  include Merb::PaginationHelper

  def index
    if params[:tag]
      @articles = @site.articles_tagged(
          params[:tag], :page => params[:page], :limit => 5)
    else
      @articles = @site.published_by_category(
          params[:category], :page => params[:page], :limit => 5)
    end
    
    display @articles
  end
  
  def by_date
    @articles = @site.published_by_date(params[:year], params[:month], params[:day],
        :page => params[:page], :limit => 5)
    
    render :index
  end

  def show
    if params[:path]
      @article = Article.first(:svn_name => params[:path], :site_id => @site.id)
    else
      @article = Article.first(:id => params[:id], :site_id => @site.id)
    end
    
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
