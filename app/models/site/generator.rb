# Update SvnFixture::Directory to add #copy_from_wistle helper method.
module SvnFixture
  class Directory 
    def copy_from_wistle(wistle_path)
      wistle_path = ::File.expand_path(
        ::File.dirname(__FILE__) + "/../../" + wistle_path)
      path = @path + wistle_path.split("/")[-1]
      FileUtils.cp(wistle_path, path)
      @ctx.add(path)
    end
  end
end

class Site
  class Generator
    def initialize(site, repos_path)
      @site = site
      @repos_path = repos_path
      @repo_name = @site.name
      @rev = 0
    end
    
    def run
      trunk_tags_branches
      basic
      SvnFixture.repo(@repo_name).commit
    end
    
    def next_rev
      @rev += 1
    end
    
    # Create "normal" base folders.
    def trunk_tags_branches
      rev = next_rev
      SvnFixture.repo(@repo_name, @repos_path) do
        rev = revision(
                rev,
                'Generate trunks, tags, and branches folders',
                :author => "wistle_generator") do
          dir 'trunk'
          dir 'tags'
          dir 'branches'
        end
      end
    end
    
    def basic
      rev = next_rev
      SvnFixture.repo(@repo_name) do
        rev = revision(
                rev,
                'Generate directory structure expected by Wistle',
                :author => "wistle_generator") do
                  
          dir 'trunk' do
            dir 'app' do
              dir 'views' do
                dir 'ads'
                dir 'articles'
                dir 'layout'
              end
            end
            
            dir 'public' do
              copy_from_wistle 'public/favicon.ico'
              
              dir 'images'
              
              dir 'javascripts'
              
              dir 'stylesheets' do
                copy_from_wistle 'public/stylesheets/master.css'
                dir 'sass' do
                  copy_from_wistle 'public/stylesheets/sass/master.sass'
                end
              end
            end
            
            dir 'articles' do
              dir 'sample' do
                prop 'ws:name', 'Sample Category'
                
                file 'sample_article.txt' do
                  prop 'ws:title', 'Sample Article'
                  prop 'ws:published_at', Time.now.strftime("%Y-%m-%d %H:%M:%S")
                  body "This is a sample article. That means this site is
                        under construction. Sorry."
                end
              end
            end
            
          end
        end
      end
    end
    
  end
end