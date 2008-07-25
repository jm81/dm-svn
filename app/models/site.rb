class Site
  include DataMapper::Resource
  
  has n, :articles
  
  property :id, Integer, :serial => true
  property :name, String, :unique => true, :nullable => false
  property :domain_regex, String
  
  # Subversion
  property :contents_uri, Text
  property :contents_revision, Integer, :default => 0
  property :username, String
  property :password, String
  property :property_prefix, String, :default => "ws:"
  property :extension, String, :default => "txt"
  
  # Content Filters
  property :article_filter, String
  property :comments_filter, String
  
  # Timestamps
  property :created_at, DateTime
  property :updated_at, DateTime

  # For SvnSync's benefit
  def uri
    @contents_uri
  end

  def revision
    @contents_revision
  end

  def revision=(rev)
    attribute_set(:contents_revision, rev)
  end
  
  # For SvnSync's benefit
  def body_property
    :body
  end
  
  def sync
    SiteSync.new(self).run
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
