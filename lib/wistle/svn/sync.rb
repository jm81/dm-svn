module Wistle
  module Svn
    class Sync
      
      attr_reader :model, :config, :repos

      def initialize(model_row)
        @model_row = model_row
        @model = Object.const_get(@model_row.name)
        @config = @model_row.config
      end
      
      # Get changesets
      def changesets
        sets = []
        
        @repos.log(@config.path_from_root, @repos.latest_revnum, @model_row.revision, 0, true, false
            ) do |changes, rev, author, date, msg|
          sets << Changeset.new(changes, rev, author, date, self)
        end
        
        sets.sort
      end
      
      # There is the possibility for uneccessary updates, as a database row may be
      # modified several times (if modified in multiple revisions) in a single
      # call. This is inefficient, but--for now--not enough to justify more
      # complex code.
      def run
        connect(@config.uri)
        return false if @repos.latest_revnum <= @model_row.revision
        
        changesets.each do |c| # Sorted by revision, ascending
          c.process          
          # Update model_row.revision
          @model_row.update_attributes(:revision => c.revision)
        end
        
        # Ensure that @model_row.revision is now set to the latest (even if there
        # weren't applicable changes in the latest revision).
        @model_row.update_attributes(:revision => @repos.latest_revnum)
        return true
      end
      
      private
      
      def connect(uri)
        @ctx = context(uri)
       
        # This will raise some error if connection fails for whatever reason.
        # I don't currently see a reason to handle connection errors here, as I
        # assume the best handling would be to raise another error.
        @repos = ::Svn::Ra::Session.open(uri, {}, callbacks)
        @config.path_from_root = @config.uri[(@repos.repos_root.length)..-1]
        return true
      end
  
      def context(uri)
        # Client::Context, which paticularly holds an auth_baton.
        ctx = ::Svn::Client::Context.new
        if @config.username && @config.password
          # TODO: What if another provider type is needed? Is this plausible?
          ctx.add_simple_prompt_provider(0) do |cred, realm, username, may_save|
            cred.username = @config.username
            cred.password = @config.password
          end
        elsif URI.parse(uri).scheme == "file" 
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
end