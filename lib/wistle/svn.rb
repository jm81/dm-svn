module Wistle
  module Svn
    class << self
      def included(klass) # Set a few 'magic' properties
        klass.extend(ClassMethods)
        
        klass.property :path, String
        klass.property :svn_created_at, DateTime
        klass.property :svn_updated_at, DateTime
        klass.property :svn_created_rev, String
        klass.property :svn_updated_rev, String
      end
    end
    
    module ClassMethods
      def config
        @config ||= Config.new
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
        @svn_repository ||= Wistle::Model.create(:name => self.name)
        @svn_repository.config = config
        @svn_repository
      end
    end
    
  end
end