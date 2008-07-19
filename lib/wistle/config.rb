module Wistle
  class Config
    OPTS = [:uri, :username, :password,
            :body_property, :property_prefix, :extension]
    
    attr_accessor *OPTS
    
    def initialize
      # Set defaults
      @body_property = 'body'
      @property_prefix = 'ws:'
      @extension = 'txt'

      # Try to set variables from database.yml.
      # The location of database.yml should, I suppose, be configurable.
      # Oh, well.
      if Object.const_defined?("RAILS_ROOT")
        f = "#{RAILS_ROOT}/config/database.yml"
        env = Kernel.const_defined?("RAILS_ENV") ? RAILS_ENV : "development"
      elsif Object.const_defined?("Merb")
        f = "#{Merb.root}/config/database.yml"
        env = Merb.env.to_sym || :development
      end
      
      if f
        config = YAML.load(IO.read(f))[env]
        OPTS.each do |field|
          config_field = config["svn_#{field}"] || config["svn_#{field}".to_sym]
          if config_field
            instance_variable_set("@#{field}", config_field)
          end
        end
      end
      
    end
  end
end
