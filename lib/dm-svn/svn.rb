module DmSvn
  module Svn
    
    class << self
      def included(klass) # Set a few 'magic' properties
        klass.extend(ClassMethods)
        
        # svn_name could be just a name, or a full path, always excluding
        # extension. If directories are stored in a model (not yet supported),
        # it contains the full path (from the config.uri).
        klass.property :svn_name, DataMapper::Property::Text, :lazy => false
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
    
    # Set the path. This may be responsible for moving the record to a different
    # parent, etc.
    def path=(value)
      attribute_set(:svn_name, value)
    end
    
    # Move to a different path and save
    def move_to(new_path)
      self.path = new_path
      self.save
    end
    
    # Update properties (body and other properties) from a DmSvn::Svn::Node
    # or similar (expects #body as a String and #properties as a Hash).
    # This method calls #save.
    def update_from_svn(node)
      attribute_set(self.class.config.body_property, node.body) if node.body
      self.path = node.short_path
      
      node.properties.each do | attr, value |
        if self.respond_to?("#{attr}=")
          self.__send__("#{attr}=", value)
        end
      end
      
      if !valid?
        puts "Invalid #{node.short_path} at revision #{node.revision}"
        puts " - " + errors.full_messages.join(".\n - ")
      end
      
      save
    end
    
    module ClassMethods
      def config
        @config ||= Config.new
      end
      
      # Override belongs_to to add +:svn+ option. If :svn => true is
      # included in the options, SvnSync will also sync the +belongs_to+ model.
      # For example, <code>belongs_to :category, :svn => true</code>, means
      # that the Category model will also be updated by SvnSync, and be based on
      # folders. Folders can have svn properties set, and/or a meta.yml file
      # with properties.
      # def belongs_to(name, options={})
      #   
      # end
      
      # Override DataMapper's +property+ class method to accept as an option
      # +body_property+. Setting this option tells DmSvn::Svn that this field
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
        
        @svn_repository = DmSvn::Model.first(:name => self.name)
        @svn_repository ||= DmSvn::Model.create(:name => self.name, :revision => 0)
        @svn_repository.config = config
        @svn_repository
      end
      
      def sync
        DmSvn::Svn::Sync.new(svn_repository).run
      end
      
      # Override normal get behavior to try to get based on path if the argument
      # is a String. Extra args are ignored by default.
      def get(path_or_id, *args)
        if path_or_id.is_a?(String)
          get_by_path(path_or_id)
        else
          super
        end
      end
      
      # Try to get by path. If not, create a new record and so set its path.
      def get_or_create(path)
        i = get_by_path(path)
        return i if i
        
        i = create
        i.path = path
        i.save
        return i
      end
      
      def get_by_path(path)
        first(:svn_name => path)
      end
    end
    
  end
end

%w{sync changeset node categorized}.each do |f|
  require "dm-svn/svn/#{f}"
end
