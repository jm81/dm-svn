module SiteSvn
  
  class Sync < Wistle::Svn::Sync
    def initialize(model_row)
      @model_row = model_row
      @model = Article
      @config = model_row
    end
    
    def site
      @model_row
    end
    
    # This is a copy of Wistle::Svn::Sync::changesets. It exists here in order
    # to call SiteSvn::Changeset.new instead of Wistle::Svn::Changeset.new
    def changesets
      sets = []
      
      @repos.log(@config.path_from_root, @repos.latest_revnum, @model_row.revision, 0, true, false
          ) do |changes, rev, author, date, msg|
        sets << Changeset.new(changes, rev, author, date, self)
      end
      
      sets.sort
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
      
      row_update = @model_row.class.get(@model_row.id)
      row_update.update_attributes("#{name}_revision" => @repos.latest_revnum)
      true
    end
    
  end
end