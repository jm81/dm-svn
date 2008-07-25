class Application < Merb::Controller
  before :sync_articles
  before :choose_site
  
  protected

  def sync_articles
    Site.sync_all
  end
  
  def choose_site
    @site = Site.by_domain(request.host)
  end
end