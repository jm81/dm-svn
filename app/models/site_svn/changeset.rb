module SiteSvn
  class Changeset < Wistle::Svn::Changeset
    def get(path)
      Article.get(@sync.site, short_path(path), true)
    end
    
    def new_record(node)
      if node.file?
        a = Article.new
        a.tmp_site = @sync.site
        a
      else
        @sync.site.categories.build
      end
    end
  end
end