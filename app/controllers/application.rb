class Application < Merb::Controller
  before :sync_articles
  
  protected

  def sync_articles
    Article.sync
  end
end