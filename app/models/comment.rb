class Comment
  include DataMapper::Resource

    property :id, Integer, :serial => true
    property :author, String, :nullable => false, :length => 100
    property :email, String, :format => :email_address
    property :body, Text, :nullable => false
    property :article_id, Integer, :nullable => false
    property :parent_id, Integer
    property :created_at, DateTime
    property :updated_at, DateTime
  
end
