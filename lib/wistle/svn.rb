module Wistle
  module Svn
    
    class << self
      def included(klass) # Set a few 'magic' properties
        klass.extend(ClassMethods)
        
        # svn_name could be just a name, or a full path, always excluding
        # extension. If directories are stored in a model (not yet supported),
        # it contains the full path (from the config.uri).
        klass.property :svn_name, DataMapper::Types::Text, :lazy => false
        klass.property :svn_created_at, DateTime
        klass.property :svn_updated_at, DateTime
        klass.property :svn_created_rev, String
        klass.property :svn_updated_rev, String
        klass.property :svn_created_by, String
        klass.property :svn_updated_by, String
      end
    end
    
    # +name+ could be reasonably used for another property, but may normally
    # be assumed to be the 'svn_name'.
    def name
      @svn_name
    end
    
    # The path from the svn root for the model. For the moment, just an alias
    # of +svn_name+.
    def path
      @svn_name
    end
    
    module ClassMethods
      def config
        @config ||= Config.new
      end
      
      # Override belong_to to add +:wistle+ option. If :wistle => true is
      # included in the options, SvnSync will also sync the +belongs_to+ model.
      # For example, <code>belongs_to :category, :wistle => true</code>, means
      # that the Category model will also be updated by SvnSync, and be based on
      # folders. Folders can have svn properties set, and/or a meta.yml file
      # with properties.
      def belongs_to(name, options={})
        
      end
      
      # Override DataMapper's +property+ class method to accept as an option
      # +body_property+. Setting this option tells Wistle::Svn that this field
      # will store the contents of the repository file.
      def property(name, type, options = {})
        if options.delete(:body_property)
          config.body_property = name.to_s
        end
        
        super(name, type, options)
      end
      
      # DataMapper uses +repository+, so prepend "svn_"
      def svn_repository
        return @svn_repository if @svn_repository
        
        @svn_repository = Wistle::Model.first(:name => self.name)
        @svn_repository ||= Wistle::Model.create(:name => self.name, :revision => 0)
        @svn_repository.config = config
        @svn_repository
      end
      
      def sync
        Wistle::SvnSync.new(svn_repository).run
      end
    end
    
  end
end