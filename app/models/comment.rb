class Comment
  include DataMapper::Resource

    property :id, Integer
    property :author, String
    property :email, String
    property :body, Text
    property :article_id, Integer
    property :parent_id, Integer
    property :created_at, DateTime
    property :updated_at, DateTime
  
end
