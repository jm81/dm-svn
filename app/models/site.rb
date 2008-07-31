class Site
  include DataMapper::Resource
  
  has n, :articles
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
    ary = contents_uri.split("/")
    ary.pop if ary[-1].blank?
    ary.pop
    ary.join("/") + "/"
  end
  
  def views_uri
    self.views_uri || (base_uri + "app/views")
  end
  
  def public_uri
    self.public_uri || (base_uri + "public")
  end
  
  # For SvnSync's benefit
  def body_property
    :body
  end
  
  def sync
    SiteSync.new(self).run
  end
  
  def categories 
    repository.adapter.query('SELECT category FROM articles WHERE site_id = ? group by category order by category', self.id)
  end
  
  def published_by_category(category = nil, options = {})
    conditions = "datetime(published_at) <= datetime('now') "
    if category
      conditions << "and path like '#{category}/%' "
    end
    Article.all(options.merge(
          :conditions => [conditions + "and site_id = ?", self.id],
          :order => [:published_at.desc]))
  end
  
  # Get all articles with a given tag
  # Round-about because I can't figure out the ambiguous column name errors
  def articles_tagged(tag)
    tag = Tag.first(:name => tag)
    return 0 unless tag
    self.taggings(:tag_id => tag.id).collect{|t| t.article}
  end

  # Count all articles with a given tag
  def count_articles_tagged(tag)
    tag = Tag.first(:name => tag)
    return 0 unless tag
    self.taggings.count(:tag_id => tag.id)
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
    
    def sync_all
      Site.all.each do |site|
        site.sync if site.contents_uri
      end
    end
  end
end
