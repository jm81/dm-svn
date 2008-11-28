class Category
  include DataMapper::Resource
  include Wistle::Svn
  include ArticleAncestor

  property :id, Integer, :serial => true
  
  belongs_to :site

  belongs_to :parent,
      :class_name => 'Category',
      :child_key => [:parent_id],
      :wistle => true
  
  include SvnExtensions
       
  has n, :children,
      :class_name => 'Category',
      :child_key => [:parent_id],
      :order => [:name.asc]
      
  has n, :articles
  
  has n, :taggings, :through => :articles
  has n, :tags, :through => :taggings

  property :parent_id, Integer
  property :name, String
  
  # Return @name if set; otherwise titleized version of svn_name.
  def name
    @name.blank? ?
      @svn_name.to_s.capitalize :
      @name    
  end
  
  # Check if any articles in the Category have been published.
  # I imagine there's a more efficient method.
  def published?
    self.published_articles.length > 0
  end
    
end