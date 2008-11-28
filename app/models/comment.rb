class Comment
  include DataMapper::Resource
  include Filters::Resource
  
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
  property :html, Text, :lazy => false
  property :body, Text, :nullable => false,
           :filter => {:to => :html, :with => :filters, :default => :site}
  property :site_id, Integer
  property :stored_article_path, Text
  property :parent_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  
  def email=(val)
    if val.blank?
      attribute_set(:email, nil)
    else
      attribute_set(:email, val)
    end
  end
  
  def site
    Article.get(@article_id).site
  end
  
  def store_article_path
    update_attributes(:stored_article_path => self.article.path)
    update_attributes(:site_id => self.article.site.id)
  end
  
  def reassociate_to_article
    self.reload # Ensure we have the latest path from database.
    
    Site.get(@site_id).articles.each do |a|
      if a.path == self.stored_article_path
        self.article_id = a.id
        self.save
        return true
      end  
    end

    return false
  end
end
