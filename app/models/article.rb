class Article
  include DataMapper::Resource
  include Wistle::Svn
  include Filters::Resource
  extend Pagination
  
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
           :filter => {:to => :html, :with => :filters, :default => :site},
           :body_property => true
  property :published_at, DateTime
  property :comments_allowed_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  
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
      attribute_set(:category, @svn_name.split('/')[0]) if @svn_name
    end
  end
  
  # The path from the svn root for the model. For the moment, just an alias
  # of +svn_name+.
  def path
    @svn_name
  end
  
  class << self
    def published(options = {})
      Article.all(options.merge(
          :conditions => ["datetime(published_at) <= datetime('now')"],
          :order => [:published_at.desc]))
    end
  end
end
