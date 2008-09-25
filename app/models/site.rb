class Site
  include DataMapper::Resource
  include ArticleAncestor

  attr_accessor :path_from_root # Used by Sync.
  
  has n, :categories, :order => [:name]
  has n, :top_level_categories,
      :class_name => 'Category',
      :parent_id => nil,
      :order => [:name]
  has n, :articles, :through => :categories
  has n, :comments
  has n, :taggings, :through => :articles
  has n, :tags, :through => :taggings
  
  property :id, Integer, :serial => true
  property :name, String, :unique => true, :nullable => false
  property :domain_regex, String
  
  # Subversion
  property :contents_uri, Text
  property :contents_revision, Integer, :default => 0
  property :views_uri, Text
  property :views_revision, Integer, :default => 0
  property :public_uri, Text
  property :public_revision, Integer, :default => 0
  property :per_page, Integer, :default => 5
  
  property :username, String
  property :password, String
  property :property_prefix, String, :default => "ws:"
  property :extension, String, :default => "txt"
  
  # Content Filters
  property :article_filter, String
  property :comment_filter, String
  
  # Timestamps
  property :created_at, DateTime
  property :updated_at, DateTime

  # For SvnSync's benefit
  def uri
    self.contents_uri
  end

  def revision
    self.contents_revision
  end

  def revision=(rev)
    attribute_set(:contents_revision, rev)
  end
  
  # A URI based off of contents_uri to use as the base for building URI's
  # for public and views
  def base_uri
    ary = contents_uri.to_s.split("/")
    ary.pop if ary[-1].blank?
    ary.pop
    ary.join("/") + "/"
  end
  
  def views_uri
    attribute_get(:views_uri) || (base_uri + "app/views")
  end
  
  def public_uri
    attribute_get(:public_uri) || (base_uri + "public")
  end
  
  # For SvnSync's benefit
  def body_property
    :body
  end
  
  def sync
    SiteSvn::Sync.new(self).run
  end
  
  # Get all articles with a given tag
  # Round-about because I can't figure out the ambiguous column name errors
  def articles_tagged(tag, options = {})
    tag = Tag.first(:name => tag)
    return 0 unless tag
    t = self.taggings(options.merge(:tag_id => tag.id))
    collection = t.collect{|tagging| tagging.article}
    collection = collection.delete_if{|a| !a.published?}
    
    collection.instance_variable_set(:@pages, t.pages)
    collection.instance_variable_set(:@current_page, t.current_page)
    def collection.pages; @pages; end
    def collection.current_page; @current_page; end
    
    collection
  end
  
  # Store the article paths for all comments.
  def store_article_paths
    # calling self.comments directly was giving frozen array errors.
    self.articles.each do |article|
      article.comments.each do |comment|
        comment.store_article_path
      end
    end
    
  end
  
  # Reassociate comments with articles based on Article#path for all comments.
  # This is designed to be used if all articles need to be reloaded from
  # Subversion repo, which would cause loss of associations.
  def reassociate_comments
    failed = []
    
    self.comments.each do |comment|
      failed << comment unless comment.reassociate_to_article
    end
    
    failed.empty? ? true : failed
  end

  # Count all articles with a given tag
  def count_articles_tagged(tag)
    tag = Tag.first(:name => tag)
    return 0 unless tag
    self.taggings.count(:tag_id => tag.id)
  end
  
  alias_method :old_articles, :articles
  
  # Override articles, so I can override articles.get to first get by path if
  # passed a string.
  def articles(*args)
    a = old_articles(*args)
    
    def a.get(path_or_id)
      if path_or_id.is_a?(String)
        Article.get(self.instance_variable_get("@parent"), path_or_id) ||
        super
      else
        super
      end
    end
    
    def a.get_published(path_or_id)
      if path_or_id.is_a?(String)
        article = 
          Article.get(self.instance_variable_get("@parent"), path_or_id, false, true) ||
          get(path_or_id)
      else
        article = get(path_or_id)
      end
      
      (article && article.published?) ? article : nil
    end
    
    a
  end
  
  class << self
    # Find a Site by domain regex, prefer longest match.
    def by_domain(val)
      possible = []
      
      Site.all.each do |s|
        r = Regexp.new(s.domain_regex.to_s, true)
        m = r.match(val)
        if m
          possible << [s, m[0].length] 
        end
      end

      possible.sort!{ |a, b| b[1] <=> a[1] }
      possible[0] ? possible[0][0] : nil
    end
    
    def reset_exports
      Site.all.each do |site|
        site.update_attributes(:views_revision => 0, :public_revision => 0)
      end
    end
    
    def sync_all(force_exports = false)
      reset_exports if force_exports
      Site.all.each do |site|
        site.sync if site.contents_uri
      end
    end
  end
end
