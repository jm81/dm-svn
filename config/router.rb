# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   r.match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   r.match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   r.match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r| 
  r.match('/').to(:controller => 'articles', :action =>'by_date').name(:root)
  r.match('/articles/sync').to(:controller => 'articles', :action => 'sync')
  r.match('/articles/sync_all').to(:controller => 'articles', :action => 'sync_all')
  r.match('/articles.xml').to(:controller => 'articles', :action => 'index', :format => "xml")
  
  r.match('/sitemap.xml').to(:controller => 'sitemap', :action => 'index', :format => "xml")
  r.match('/sitemap').to(:controller => 'sitemap', :action => 'index').name(:sitemap)
  r.match('/robots.txt').to(:controller => 'sitemap', :action => 'robots', :format => "txt")
  
  r.match(%r[/search/results]).to(
    :controller => 'articles', :action => 'search')
  
  r.match(%r[/tags/(.*)]).to(
     :controller => 'articles', :action => 'by_tag', :tag => '[1]')
     
  r.match(%r[(.*)/comments]) do |c|
    c.match(%r[/new\Z]).to(:path => '[1]', :action => 'new', :controller => 'comments')
    c.match(%r[/(\d+)\Z]).to(:path => '[1]', :action => 'show', :controller => 'comments', :id => '[2]')
    c.match('', :method => :post).to(:path => '[1]', :action => 'create', :controller => 'comments')
    c.match('').to(:controller => 'articles', :action => 'by_path', :path => '[1]')
  end
     
  # I really don't understand Merb routing
  r.match(%r[/(\d{4})]) do |a|
    a.match(%r[/(\d{1,2})/(\d{1,2})]).to(:year => '[1]', :month => '[2]', :day => '[3]', :action => 'by_date', :controller => 'articles')
    a.match(%r[/(\d{1,2})]).to(:year => '[1]', :month => '[2]', :action => 'by_date', :controller => 'articles')
    a.match('').to(:year => '[1]', :action => 'by_date', :controller => 'articles')
  end
  
  r.match(%r[/(.*)]).to(
     :controller => 'articles', :action => 'by_path', :path => '[1]').name(:article_path)
end