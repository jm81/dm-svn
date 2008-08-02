class Application < Merb::Controller 
  def render(thing = nil, opts = {})
    self.class._template_roots << ["#{Merb.root}/app/sites/#{@site.name}/views", :_template_location]
    ret = super
    self.class._template_roots.pop
    ret
  end
  
  before :choose_site
  
  protected
  
  def choose_site
    @site = Site.by_domain(request.host)
  end

end