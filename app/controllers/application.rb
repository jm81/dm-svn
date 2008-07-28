class Application < Merb::Controller 
  def render(thing = nil, opts = {})
    self.class._template_roots << ["/u/apps/w2/app/sites/#{@site.name}/views", :_template_location]
    ret = super
    self.class._template_roots.pop
    ret
  end
  
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