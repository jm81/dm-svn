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
        
        # On create, set svn_created_* attrs based on svn_updated_* attrs
        klass.before :create do
          attribute_set(:svn_created_at, svn_updated_at)
          attribute_set(:svn_created_rev, svn_updated_rev)
          attribute_set(:svn_created_by, svn_updated_by)
        end
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
    
    # Update properties (body and other properties) from a Wistle::Svn::Node
    # or similar (expects #body as a String and #properties as a Hash).
    # This method calls #save.
    def update_from_svn(node)
      attribute_set(self.class.config.body_property, node.body)
      
      node.properties.each do | attr, value |
        attribute_set(attr, value)
      end
      
      save
    end
    
    module ClassMethods
      def config
        @config ||= Config.new
      end
      
      # Override belongs_to to add +:wistle+ option. If :wistle => true is
      # included in the options, SvnSync will also sync the +belongs_to+ model.
      # For example, <code>belongs_to :category, :wistle => true</code>, means
      # that the Category model will also be updated by SvnSync, and be based on
      # folders. Folders can have svn properties set, and/or a meta.yml file
      # with properties.
      # def belongs_to(name, options={})
      #   
      # end
      
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
        Wistle::Svn::Sync.new(svn_repository).run
      end
      
      # Override normal get behavior to try to get based on path if the argument
      # is a String.
      def get(path_or_id)
        if path_or_id.is_a?(String)
          get_by_path(path_or_id)
        else
          super
        end
      end
      
      def get_by_path(path)
        first(:svn_name => path)
      end
    end
    
  end
end

%w{sync changeset node}.each do |f|
  require File.dirname(__FILE__) + "/svn/#{f}.rb"
end