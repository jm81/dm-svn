module Wistle
  class SvnSync
    def initialize(model_row)
      @model_row = model_row
      @model = Object.const_get(@model_row.name)
      @config = @model_row.config
    end
    
    # There is the possibility for uneccessary updates, as a database row may be
    # modified several times (if modified in multiple revisions) in a single
    # call. This is inefficient, but--for now--not enough to justify more
    # complex code.
    def run
      connect unless @repos
      return false if @repos.latest_revnum <= @model_row.revision
      
      changesets = [] # TODO Maybe revision + 1
      @repos.log(@path_from_root, @repos.latest_revnum, @model_row.revision, 0, true, false
          ) do |changes, rev, author, date, msg|
        changesets << [changes, rev, author, date]
      end
      
      changesets.sort{ |a, b| a[1] <=> b[1] }.each do |c| # Sort by revision
        do_changset(*c)
      end
      
      # Ensure that @model_row.revision is now set to the latest (even if there
      # weren't applicable changes in the latest revision).
      @model_row.update_attributes(:revision => @repos.latest_revnum)
      return true
    end
    
    private
    
    # Get the relative path from config.uri
    def short_path(path)
      path = path[@path_from_root.length..-1]
      path = path[1..-1] if path[0] == ?/
      path.sub!(/\.#{@config.extension}\Z/, '') if @config.extension
      path
    end
    
    # Get an object of the @model, by path.
    def get(path)
      @model.first(:path => short_path(path))
    end
    
    # Process a single changset.
    # This doesn't account for possible move/replace conflicts (A node is moved,
    # then the old node is replaced by a new one). I assume those are rare
    # enough that I won't code around them, for now.
    def do_changset(changes, rev, author, date)
      modified, deleted, copied = [], [], []
      
      changes.each_pair do |path, change|
        next if short_path(path).blank?
        
        case change.action
        when "M", "A", "R" # Modified, Added or Replaced
          modified << path if @repos.stat(path, rev).file?
        when "D"
          deleted << path
        end
        copied << [path, change.copyfrom_path] if change.copyfrom_path        
      end
            
      # Perform moves
      copied.each do |copy|
        del = deleted.find { |d| d == copy[1] }
        if del
          # Change the path. No need to perform other updates, as this is an
          # "A" or "R" and thus is in the +modified+ Array.
          record = get(del)
          record.update_attributes(:path => short_path(copy[0])) if record
        end
      end
      
      # Perform deletes
      deleted.each do |path|
        record = get(path)
        record.destroy if record # May have been moved or refer to a directory
      end
      
      # Perform modifies and adds
      modified.each do |path|
        next if @config.extension && path !~ /\.#{@config.extension}\Z/
        
        record = get(path) || @model.new
        svn_file = @repos.file(path, rev)
        
        # update body
        record.__send__("#{@config.body_property}=", svn_file[0])

        # update node props -- just find any props with property_prefix
        svn_file[1].each do |name, val|
          if name =~ /\A#{@config.property_prefix}(.*)/
            record.__send__("#{$1}=", val)
          end
        end

        # update revision props
        record.path = short_path(path)
        record.svn_updated_at = date
        record.svn_updated_rev = rev
        record.svn_updated_by = author
        if record.new_record?
          record.svn_created_at = date
          record.svn_created_rev = rev
          record.svn_created_by = author
        end
        record.save
      end
      
      # Update model_row.revision
      @model_row.update_attributes(:revision => rev)
    end
    
    def connect
      @ctx = context
     
      # This will raise some error if connection fails for whatever reason.
      # I don't currently see a reason to handle connection errors here, as I
      # assume the best handling would be to raise another error.
      @repos = ::Svn::Ra::Session.open(@config.uri, {}, callbacks)
      @path_from_root = @config.uri[(@repos.repos_root.length)..-1]
      return true
    end

    def context
      # Client::Context, which paticularly holds an auth_baton.
      ctx = ::Svn::Client::Context.new
      if @config.username && @config.password
        # TODO: What if another provider type is needed? Is this plausible?
        ctx.add_simple_prompt_provider(0) do |cred, realm, username, may_save|
          cred.username = @config.username
          cred.password = @config.password
        end
      elsif URI.parse(@config.uri).scheme == "file" 
        ctx.add_username_prompt_provider(0) do |cred, realm, username, may_save|
          cred.username = @config.username || "ANON"
        end
      else
        ctx.auth_baton = ::Svn::Core::AuthBaton.new()
      end
      ctx
    end
  
    # callbacks for Svn::Ra::Session.open. This includes the client +context+.
    def callbacks
      ::Svn::Ra::Callbacks.new(@ctx.auth_baton)
    end
  end
end