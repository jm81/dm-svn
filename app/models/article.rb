class Article
  include DataMapper::Resource
  
  has n, :comments
 
  has n, :direct_comments,
      :class_name => 'Comment',
      :order => [:created_at.desc],
      :parent_id => nil

    property :id, Integer, :serial => true
    property :title, String
    property :body, Text, :lazy => false
    property :published_at, DateTime
    property :comments_allowed_at, DateTime
    property :created_at, DateTime
    property :updated_at, DateTime
  
end
