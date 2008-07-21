require File.dirname(__FILE__) + '/../wistle/fixture.rb'

DataMapper.setup(:mephisto, 'sqlite3:///u/data/wistle/import.db')
 
class Content
  include DataMapper::Resource
  
  repository(:mephisto) do
    property :id, Integer, :serial => true
    property :article_id, Integer
    property :user_id, Integer
    property :permalink, String
    property :title, String
    property :body, Text, :lazy => false
    property :type, String
    property :author, String
    property :author_email, String
    property :site_id, Integer
    property :filter, String
  end
end

class ContentVersion
  include DataMapper::Resource
  
  repository(:mephisto) do
    property :id, Integer, :serial => true
    property :article_id, Integer
    property :user_id, Integer
    property :permalink, String
    property :title, String
    property :body, Text, :lazy => false
    property :author, String
    property :author_email, String
    property :site_id, Integer
    property :filter, String
    property :updated_at, DateTime
    property :content_id, Integer
    property :version, Integer
    property :versioned_type, String
  end
  
end

# Check to run for multiple permalinks:
# select permalink, count(id) as c from contents where type='Article' group by permalink having c > 1;

module Migrations
  class Mephisto
    def initialize(name, site_id)
      @site_id = site_id
      @name = name
      
      #File.open("#{@repo_path}/hooks/pre-revprop-change", 'w') do |f|
      #  f.write "#!/bin/sh\n\nexit 0\n"
      #end
      #`chmod u+x #{@repo_path}/hooks/pre-revprop-change`
    end
  
    def run
      site_id = @site_id

      svn_repo(@name) do
        rev = 1
        revision(rev, 'Generate articles directory (Wistle Migration)',
            :date => Time.parse("2007-01-01")) do
          dir 'articles'
        end

        repository(:mephisto) do
          versions = ContentVersion.all(:site_id => site_id, :versioned_type => 'Article', :order => [:updated_at.asc])

          versions.each do |v|
            article = Content.get(v.article_id)
            commit_type = v.version == 1 ? "Create" : "Update"
            
            revision(rev += 1,
                "#{commit_type} article #{article.permalink} (Wistle Migration)",
                :author => 'jmorgan', #TODO: real name
                :date => v.updated_at
              ) do
  
              dir 'articles' do
                file "#{article.permalink}.txt" do
                  prop 'dm:title', v.title
                  prop 'dm:filter', v.filter.gsub('_filter', '')
                  body v.body
                end
              end # dir
            end # revision
            
          end
        end
      end
      
      svn_repo(@name).create.commit
      return true
    end
  end
end
