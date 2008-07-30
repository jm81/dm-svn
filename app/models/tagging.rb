class Tagging
  include DataMapper::Resource
  
  property :id, Integer, :serial => true
  property :article_id, Integer
  property :tag_id, Integer
  
  belongs_to :tag
  belongs_to :article
end