module Wistle
  class Model
    include DataMapper::Resource
  
    property :id, Integer, :serial => true
    property :name, String
    property :revision, Integer
    
    # Wistle::Config object
    attr_accessor :config
  end
end