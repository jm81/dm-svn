class Article
  include DataMapper::Resource
  include Filters::Resource
  
  # Setup Wistle::Config info here or in database.yml
  
  belongs_to :site
  has n, :comments
 
  has n, :direct_comments,
      :class_name => 'Comment',
      :order => [:created_at.asc],
      :parent_id => nil

    property :id, Integer, :serial => true
    property :site_id, Integer
    property :title, String
    property :html, Text, :lazy => false
    property :body, Text,
             :filter => {:to => :html, :with => :filters, :default => %w{Markdown Smartypants}}
    property :published_at, DateTime
    property :comments_allowed_at, DateTime
    property :created_at, DateTime
    property :updated_at, DateTime
    
    # Subversion-specific properties
    property :path, String
    property :svn_created_at, DateTime
    property :svn_updated_at, DateTime
    property :svn_created_rev, String
    property :svn_updated_rev, String
    property :svn_created_by, String
    property :svn_updated_by, String
  
  # Set boolean from timestamp methods:
  # - {name}?
  # - {name}= (must allow for '0' as this is what checkboxes may return.)
  %w{published comments_allowed}.each do | col |
    define_method("#{col}=") do |value|
      value = false if (value == '0' || value == 0)
      if (!value == __send__("#{col}?"))
        attribute_set("#{col}_at", value ? Time.now : nil)
      end
    end

    define_method("#{col}?") do
      __send__("#{col}_at") ? true : false
    end
  end
  
  # Returns the numbers of comments that belong to this Article.
  # There's probably a better way to do this.
  def comments_count
    Comment.count(:article_id => @article.id)
  end
  
  class << self
    def published(options = {})
      Article.all(options.merge(
          :conditions => ["datetime(published_at) <= datetime('now')"],
          :order => [:published_at.desc]))
    end
  end
end
