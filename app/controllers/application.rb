class Application < Merb::Controller  
  before :choose_site
  before :update_template_roots
  after :revert_template_roots
  
  protected
  
  def choose_site
    @site = Site.by_domain(request.host)
  end
  
  def update_template_roots
    self.class._template_roots = [
      ["#{Merb.root}/app/views", :_template_location],
      ["#{Merb.root}/app/sites/#{@site.name}/views", :_template_location]
    ]
    Sass::Plugin.options[:template_location] = Merb.root + "/public/sites/#{@site.name}/stylesheets/sass"
    Sass::Plugin.options[:css_location] = Merb.root + "/public/sites/#{@site.name}/stylesheets"
  end

  def revert_template_roots
    self.class._template_roots = [
      ["#{Merb.root}/app/views", :_template_location]
    ]
  end
end