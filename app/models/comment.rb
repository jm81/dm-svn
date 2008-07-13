class Comment
  include DataMapper::Resource
  
  belongs_to :article
  
  belongs_to :parent,
      :class_name => 'Comment',
      :child_key => [:parent_id]
       
  has n, :replies,
      :class_name => 'Comment',
      :child_key => [:parent_id],
      :order => [:created_at.asc]

    property :id, Integer, :serial => true
    property :author, String, :nullable => false, :length => 100
    property :email, String, :format => :email_address
    property :body, Text, :nullable => false, :lazy => false
    property :article_id, Integer, :nullable => false
    property :parent_id, Integer
    property :created_at, DateTime
    property :updated_at, DateTime
  
end
