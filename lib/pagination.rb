module Pagination
    
  # Add pagination support to Article.all by introduction :page option. This
  # is the page number (beginning at 1). :limit, naturally, represents the
  # number of articles per page.
  def all(options = {})
    page = options.delete(:page).to_i
    page = 1 if page < 1
    limit = (options[:limit] || 10).to_i
    options[:offset] = ((page - 1) * limit)
    collection = super(options)

    [:offset, :limit, :order].each do |key|
      options.delete(key)
    end
    
    # Create +pages+ and +current_page+ methods for collection, for use by
    # pagination links.
    collection.instance_variable_set(:@pages, ((self.count(options) - 1) / limit) + 1)
    collection.instance_variable_set(:@current_page, page)
    def collection.pages; @pages; end
    def collection.current_page; @current_page; end  
    
    collection
  end
end