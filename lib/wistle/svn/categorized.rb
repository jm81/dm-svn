module Wistle
  module Svn
    
    module ClassMethods
      
      # Override belongs_to to add a :wistle option if :wistle => true, include
      # Categorized and set up @svn_category and @svn_category_model instance
      # methods.
      def belongs_to(what, options = {})
        ws = options.delete(:wistle)
        if ws
          @svn_category = what
          @svn_category_model = options[:class_name] || what.to_s.camel_case
          include(Wistle::Svn::Categorized)
        end
        
        super
      end
      
      # Method name for accessing the parent instance.
      def svn_category
        @svn_category
      end
      
      # Name of the parent model class (as a String)
      def svn_category_model
        @svn_category_model
      end
      
    end
    
    # This module is including when belongs_to is called with :wistle => true.
    # It overrides #path and #path= to take into account categories (folders in 
    # the Subversion repository). It also overrides .get to accept get_parent
    # argument.
    module Categorized
      class << self
        def included(klass)
          klass.extend(ClassMethods)
        end
      end
      
      # The path from the svn root for the model. Includes any folders.
      def path
        cat = self.send(self.class.svn_category)
        
        if cat && !cat.path.blank?
          return cat.path + "/" + @svn_name
        end
        
        return @svn_name
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
          category = category_model.get_or_create(parent)
          self.send("#{self.class.svn_category}=", category)
        end
        
        attribute_set(:svn_name, immediate)
      end
      
      module ClassMethods
        
        # Get by path, which gets parent (possibly recursively) first.
        def get_by_path(value)
          value = value[1..-1] while value[0..0] == "/"
          ary = value.split("/")
          immediate = ary.pop
          parent = ary.join("/")
          
          if parent.blank?
            first(:svn_name => immediate, "#{self.svn_category}_id".to_sym => nil)
          else
            category_model = Object.const_get(self.svn_category_model)
            category = category_model.get_by_path(parent)
            return nil if category.nil?
            first(:svn_name => immediate, "#{self.svn_category}_id".to_sym => category.id)
          end
        end
        
        # Add get_parent argument. If true and a path is not found for the 
        # model, try to find path in parent model (if any).
        def get(path_or_id, get_parent = false)
          if path_or_id.is_a?(String)
            i = get_by_path(path_or_id)
            if i || !get_parent
              return i 
            else # if get_parent
              category_model = Object.const_get(@svn_category_model)
              return nil if category_model == self.class
              category_model.get_by_path(path_or_id)
            end
          else
            super(path_or_id)
          end
        end
        
      end
    
    end
  end
end
