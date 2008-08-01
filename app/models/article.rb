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
  
  has n, :taggings
  has n, :tags, :through => :taggings, :links => [:tagging]

    property :id, Integer, :serial => true
    property :site_id, Integer
    property :title, String, :length => 255
    property :html, Text, :lazy => false
    property :body, Text,
             :filter => {:to => :html, :with => :filters, :default => :site}
    property :published_at, DateTime
    property :comments_allowed_at, DateTime
    property :created_at, DateTime
    property :updated_at, DateTime
    
    # Subversion-specific properties
    property :path, String, :length => 255
    property :svn_created_at, DateTime
    property :svn_updated_at, DateTime
    property :svn_created_rev, String
    property :svn_updated_rev, String
    property :svn_created_by, String
    property :svn_updated_by, String
    
    property :category, String
    before :save, :update_category
  
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
  
  # Sets tags.
  # Accepts a semi-colon delimited list (or an Array)
  # Existing taggings are deleted.
  def tags=(t)
    self.taggings.each {|tagging| tagging.destroy}
    self.taggings.reload
    t = t.split(';') unless t.is_a?(Array)
    t.each do |name|
      name = name.strip
      tag = Tag.first(:name => name) || Tag.create(:name => name)
      self.taggings.create(:tag => tag)
    end
  end
  
  def update_category
    if attribute_dirty?(:category) || @category.nil?
      attribute_set(:category, @path.split('/')[0]) if @path
    end
  end
  
  class << self
    def published(options = {})
      Article.all(options.merge(
          :conditions => ["datetime(published_at) <= datetime('now')"],
          :order => [:published_at.desc]))
    end
  end
end
