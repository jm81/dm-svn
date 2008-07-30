class Tag
  include DataMapper::Resource
  
  property :id, Integer, :serial => true
  property :name, String
  
  has n, :taggings
  has n, :articles, :through => :taggings
end