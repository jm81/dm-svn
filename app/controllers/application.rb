class Application < Merb::Controller  
  before :choose_site
  before :update_sass_locations
  
  protected
  
  def choose_site
    @site = Site.by_domain(request.host)
  end
  
  def _template_location(context, type, controller)
    with_extension = _conditionally_append_extension(controller ? "#{controller}/#{context}" : "#{context}", type)
    if Dir.glob("#{Merb.root}/app/sites/#{@site.name}/views/#{with_extension}.*").empty?
      with_extension
    else
      "../sites/#{@site.name}/views/#{with_extension}"
    end
  end
  
  def update_sass_locations
    Sass::Plugin.options[:template_location] = Merb.root + "/public/sites/#{@site.name}/stylesheets/sass"
    Sass::Plugin.options[:css_location] = Merb.root + "/public/sites/#{@site.name}/stylesheets"
  end
end