module DmSvn
  class Model
    include DataMapper::Resource
  
    property :id, Serial
    property :name, String
    property :revision, Integer
    
    # DmSvn::Config object
    attr_accessor :config
  end
end