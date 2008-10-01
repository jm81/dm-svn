require File.expand_path(File.dirname(__FILE__) + "/../../../lib/wistle/fixture.rb")

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
      svn_repo(@repo_name).create.commit
    end
    
    def next_rev
      @rev += 1
    end
    
    # Create "normal" base folders.
    def trunk_tags_branches
      rev = next_rev
      svn_repo(@repo_name, @repos_path) do
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
      svn_repo(@repo_name) do
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
            
            dir 'articles'
            
          end
        end
      end
    end
    
  end
end