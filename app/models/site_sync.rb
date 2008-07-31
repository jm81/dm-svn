class SiteSync < Wistle::SvnSync
  def initialize(model_row)
    @model_row = model_row
    @model = Article
    @config = model_row
  end
  
  # Get an Article by site and path.
  def get(path)
    Article.first(:site_id => @model_row.id, :path => short_path(path))
  end
  
  def new_record
    @model.create(:site_id => @model_row.id)
  end
  
  def run
    super
    export_views
    export_public
  end
  
  def export_views
    export("views", File.join(Merb::root, "app", "sites", @model_row.name, "views"))
  end
  
  def export_public
    export("public", File.join(Merb::root, "public", "sites", @model_row.name))    
  end
  
  def export(name, export_path)
    export_path = File.expand_path(export_path)
    uri = @model_row.__send__("#{name}_uri")
    rev = @model_row.__send__("#{name}_revision")
    connect(uri)
    return false if @repos.latest_revnum <= rev
    updated_rev = @repos.stat(uri[(@repos.repos_root.length)..-1], @repos.latest_revnum).created_rev
    return false if updated_rev <= rev
    
    FileUtils.mkdir_p(export_path)
    FileUtils.rm_rf(export_path)
    @ctx.export(uri, export_path)
    @model_row.update_attributes("#{name}_revision" => @repos.latest_revnum)
    true
  end
end