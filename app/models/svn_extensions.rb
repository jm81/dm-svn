# Override path / get related methods to include site.
module SvnExtensions
  class << self
    def included(klass)
      klass.extend(ClassMethods)
    end
  end
    
  # Set the path. This is responsible for moving the record to a different
  # parent, etc.
  def path=(value)
    value = value[1..-1] while value[0..0] == "/"
    ary = value.split("/")
    immediate = ary.pop
    parent = ary.join("/")
    
    if parent.blank?
      self.send("#{self.class.svn_category}=", nil)
    else
      category_model = Object.const_get(self.class.svn_category_model)
      category = category_model.get_or_create(self.site, parent) # Only change
      self.send("#{self.class.svn_category}=", category)
    end
    
    attribute_set(:svn_name, immediate)
  end
      
  module ClassMethods
    
    # Get by path, which gets parent (possibly recursively) first.
    def get_by_path(site, value, published_only = false)
      value = value[1..-1] while value[0..0] == "/"
      ary = value.split("/")
      immediate = ary.pop
      parent = ary.join("/")
      published_opts = published_only ? 
        {:conditions => ["datetime(published_at) <= datetime('now')"]} : {}
      
      if parent.blank?
        site.__send__(self.name.downcase.plural).first(published_opts.merge(:svn_name => immediate, "#{self.svn_category}_id".to_sym => nil))
      else
        category_model = Object.const_get(self.svn_category_model)
        category = category_model.get_by_path(site, parent)
        return nil if category.nil?
        site.__send__(self.name.downcase.plural).first(published_opts.merge(:svn_name => immediate, "#{self.svn_category}_id".to_sym => category.id))
      end
    end
    
    # Add get_parent argument. If true and a path is not found for the 
    # model, try to find path in parent model (if any).
    def get(site_or_id, path = nil, get_parent = false, published_only = false)
      if path.is_a?(String)
        i = get_by_path(site_or_id, path, published_only)
        if i || !get_parent
          return i 
        else # if get_parent
          category_model = Object.const_get(@svn_category_model)
          return nil if category_model == self.class
          category_model.get_by_path(site_or_id, path)
        end
      else
        site_or_id = site_or_id.to_i unless site_or_id.is_a?(Site)
        super(site_or_id)
      end
    end
    
    # Try to get by path. If not, create a new record and so set its path.
    def get_or_create(site, path)
      i = get_by_path(site, path)
      return i if i
      
      i = site.__send__(self.name.downcase.plural).create
      i.path = path
      i.save
      return i
    end
    
  end
end
