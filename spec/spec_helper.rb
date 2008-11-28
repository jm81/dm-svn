require 'rubygems'
require 'merb-core'
require 'spec' # Satiates Autotest and anyone else not using the Rake tasks

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end

# for temporarily disabling one set of specs.
def dont_describe(*args)
  nil
end

# auto_migrate one or more models
def migrate(*klasses)
  klasses.each do |klass|
    klass.auto_migrate!
  end
end

# Delete all entries in one or more models
def clean(*klasses)
  klasses.each do |klass|
    klass.all.each {|entry| entry.destroy}
  end
end

# These setup_* methods are designed to quickly setup a chain of relationships,]
# when I only particularly care about the end of the chain. Site -> Category ->
# Article -> Comment
def setup_site(attrs = {})
  Site.create(attrs.merge(:name => "Test Site #{Site.count}"))
end

def setup_category(site = nil, attrs = {})
  site = setup_site unless site.kind_of?(Site)
  site.categories.create({:name => "Test Category"}.merge(attrs))
end

def setup_article(category = nil, attrs = {})
  if category.kind_of?(Site)
    category = setup_category(category)
  elsif !category.kind_of?(Category)
    category = setup_category
  end
  
  category.articles.create(
      {:title => "Test Article", :body => "A test"}.merge(attrs))
end

def setup_comment(article = nil, attrs = {})
  if article.kind_of?(Site) || article.kind_of?(Category)
    article = setup_article(article)
  elsif !article.kind_of?(Article)
    article = setup_article
  end
  
  article.comments.create(
     {:author => "author", :body => "A comment"}.merge(attrs))
end

# Load a fixture and return the repos uri.
def load_svn_fixture(name)
  script = File.expand_path(File.join(File.dirname(__FILE__), "wistle", "fixtures", "#{name}.rb" ))
  require script
  repos_path = File.join(File.dirname(__FILE__), "..", "lib", "wistle", "tmp", "repo_#{name}" )
  return "file://" + File.expand_path(repos_path) + "/articles"
end