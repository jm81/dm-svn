require 'dm-migrations'

# Categories will need to be recommitted after migration to have sync recognize
# their properties. This is acceptable because it's not an issue for me and
# as far as I know, I'm the only one using the 0.1 version.

class From_0_1
  def self.run
    Article.property :path, String, :length => 255
    Article.property :site_id, Integer
    
    Article.repository.auto_upgrade!
    Article.all.each do |a|

      # Set svn_name to value of path (if needed)
      if a.svn_name.nil?
        a.svn_name = a.attribute_get(:path)
      end
      
      a.save
      
      # Setup category structure; letting Article#path= do the heavy lifting.
      site = Site.get(a.attribute_get(:site_id))
      a.tmp_site = site
      a.path = a.svn_name
      a.save
    end
    
  end
end

From_0_1.run
