require 'category'

class Article
  include DataMapper::Resource
  include Wistle::Svn
  include Filters::Resource
  extend Paginate::DM
  
  property :id, Integer, :serial => true
  
  belongs_to :category, :wistle => true
  include SvnExtensions
  
  attr_accessor :tmp_site # Used by Sync
  
  # Get site through category
  def site
    # Something to do with when things are processed means this method
    # makes filters happy instead of doing a self.category.site
    @tmp_site ||
      Category.get(@category_id).site
  end
  
  has n, :comments
 
  has n, :direct_comments,
      :class_name => 'Comment',
      :order => [:created_at.asc],
      :parent_id => nil
  
  has n, :taggings
  has n, :tags, :through => :taggings, :links => [:tagging]
  
  property :category_id, Integer
  property :title, String, :length => 255
  property :html, Text, :lazy => false
  property :body, Text,
           :filter => {:to => :html, :with => :filters, :default => :site},
           :body_property => true
  property :published_at, DateTime
  property :comments_allowed_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  
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
  
  # Checks both that published_at has been set, and is not in the future.
  def published?
    (published_at && published_at <= DateTime.now) ? true : false
  end
    
  # Sets tags.
  # Accepts a semi-colon delimited list (or an Array)
  # Existing taggings are deleted.
  def tags=(t)
    self.save if self.new_record?
    self.taggings.each {|tagging| tagging.destroy}
    self.taggings.reload
    t = t.split(';') unless t.is_a?(Array)
    t.each do |name|
      name = name.strip
      tag = Tag.first(:name => name) || Tag.create(:name => name)
      self.taggings.create(:tag => tag)
    end
  end
end
