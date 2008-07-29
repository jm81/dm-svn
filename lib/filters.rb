# This module enables a property to be filtered on save into another property,
# using per-row and/or per-property filters. The syntax when defining a property
# is:
#   property :prop_name, :filter => {:to => :filtered_prop, :with => :filter_column, :default => "DefaultFilter"}
#   (:with and :default are optional, though at least one should be specified.)
#
# If the properties in :to and :with have not yet been defined, they will be
# defined automatically. Hence, if want to specify any options with this, they
# should be defined before to filtered property.

module Filters
  
  # A hash, with each entry of the form:
  # Filter name (used in +filters+ property) => 
  #  Array of two elements Arrays representing classes that can process this
  # filter. Elements are: [ argument_for_require, class_name ].
  # Classes are assumed to respond to +to_html+.
  AVAILABLE_FILTERS = {
    'Smartypants' => [['rubypants', 'RubyPants']],
    'Markdown' => [['rdiscount', 'RDiscount'], ['bluecloth', 'BlueCloth']],
    'Textile' => [['redcloth', 'RedCloth']]
  }
  
  def self.process(filters, content)
    return content if filters.nil?
    
    filters = filters.split(';') if filters.kind_of?(String)
    filters.each do |name|
      filter = get_filter(name)
      next unless filter
      content = filter.new(content).to_html
    end
    content
  end
  
  def self.get_filter(name)
    name = name.strip.camel_case
    info = AVAILABLE_FILTERS[name]
    return(nil) unless info
      
    # Try to find loaded class
    info.each do |c|
      return Object.const_get(c[1]) if Object.const_defined?(c[1])
    end
    
    # Try to require a class
    info.each do |c|
      begin
        require(c[0])
        return Object.const_get(c[1])
      rescue LoadError
        # Try next
      end
    end
    
    return nil
  end
  
  # Filters::Resource can be included in a model to enable the
  # :filtered_to => (name of other property) option for +properties+.
  # This adds a property name "filters", which is a semi-colon delimited list
  # of filters through which to process the original property.  
  module Resource
    class << self
      def included(klass) # Set a few 'magic' properties
        klass.extend(ClassMethods)
        klass.before :save, :process_filters
      end
    end
      
    # Process and filters for @filtered_properties.
    def process_filters
      return if self.class.filtered_properties.nil?
      self.class.filtered_properties.each do |f|
        if attribute_dirty?(f[:name])
          filters = nil
          if !f[:with].blank?
            if f[:with].kind_of?(Symbol)
              filters = self.__send__(f[:with])
            else
              filters = f[:with]
            end
          end
          if filters.blank?
            filters = f[:default]
          end
          if filters == :site
            filters = self.site.__send__("#{self.class.name.snake_case}_filter")
          end
          attribute_set(f[:to], Filters.process(filters, self.__send__(f[:name])))
        end
      end
    end

    module ClassMethods
      # Override DataMapper's +property+ class method to accept as an option
      # +filter+. +filter+ Hash with the following pairs:
      # - +:to+ - Name of property to filter to; this should not be explicitly
      #   declared as a property.
      # - +:with+ - Either 1) Name of the property (as a symbol) that designates
      #   filter (does  not need to be explicitly declared as a property) or
      #   2) A semi-colon delimited String represented filters to use (or an
      #   Array of strings).
      # - +:default+ - A semi-colon delimited String represented filters to use
      #   (or an Array of strings) if the filter column is blank.
      def property(name, type, options = {})
        if filter = options.delete(:filter)
          @filtered_properties ||= []
          @filtered_properties << filter.merge({:name => name})
          begin
            self.properties[filter[:to].to_s]
          rescue
            self.property(filter[:to], type)
          end
          if filter[:with].kind_of?(Symbol)
            begin
              self.properties[filter[:with].to_s]
            rescue
              self.property(filter[:with], String)
            end
          end
        end
        
        super(name, type, options)
      end
      
      def filtered_properties
        begin
          # This is to work with STI models. It's not a very good solution.
          @filtered_properties || self.superclass.filtered_properties
        rescue
          nil
        end
      end
    end
  end
end
