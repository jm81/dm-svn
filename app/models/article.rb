class Article
  include DataMapper::Resource

    property :id, Integer, :serial => true
    property :title, String
    property :body, Text
    property :published_at, DateTime
    property :comments_allowed_at, DateTime
    property :created_at, DateTime
    property :updated_at, DateTime
  
end
