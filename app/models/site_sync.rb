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
    @model.new(:site_id => @model_row.id)
  end
end