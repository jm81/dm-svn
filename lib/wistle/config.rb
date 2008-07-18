module Wistle
  class Config
    attr_accessor :body_property
    
    def initialize
      # Set defaults
      @body_property = 'body'
    end
  end
end