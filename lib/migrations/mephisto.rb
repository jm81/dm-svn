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
    property :version, Integer
    property :filter, String
    property :created_at, DateTime
    property :updated_at, DateTime
    property :published_at, DateTime
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
    property :created_at, DateTime
    property :updated_at, DateTime
    property :published_at, DateTime
    property :content_id, Integer
    property :version, Integer
    property :versioned_type, String
  end
  
end

class AssignedSection
  include DataMapper::Resource
  
  repository(:mephisto) do
    property :id, Integer, :serial => true
    property :article_id, Integer
    property :section_id, Integer
  end
end

class Section
  include DataMapper::Resource
  
  repository(:mephisto) do
    property :id, Integer, :serial => true
    property :site_id, Integer
    property :path, String
  end
end

class MephistoTagging
  include DataMapper::Resource

  repository(:mephisto) do
    @storage_names[:mephisto] = 'taggings'
    
    property :id, Integer, :serial => true
    property :taggable_id, Integer
    property :taggable_type, String
    property :tag_id, Integer
  end
end

class MephistoTag
  include DataMapper::Resource
  
  repository(:mephisto) do
    @storage_names[:mephisto] = 'tags'
    
    property :id, Integer, :serial => true
    property :name, String
  end
end

# Check to run for multiple permalinks:
# select permalink, count(id) as c from contents where type='Article' group by permalink having c > 1;
# select article_id, count(article_id) as c from assigned_sections group by article_id having c > 1;

module Migrations
  class Mephisto
    def initialize(name, site_id)
      @site_id = site_id
      @name = name
    end

    def run
      site_id = @site_id

      svn_repo(@name) do
        rev = 1
        revision(rev, 'Generate tags, trunk and branches directories (Wistle Migration)',
            :author => 'jmorgan',
            :date => Time.parse("2005-10-01")) do
          dir 'tags'
          dir 'branches'
          dir 'trunk'
        end
        
        revision(rev += 1, 'Generate articles directory (Wistle Migration)',
            :author => 'jmorgan',
            :date => Time.parse("2005-10-01")) do
          dir 'trunk' do
            dir 'articles'
          end
        end

        repository(:mephisto) do
          versions = ContentVersion.all(:site_id => site_id, :versioned_type => 'Article', :order => [:updated_at.asc])

          versions.each do |v|
            article = Content.get(v.article_id)
            
            section_paths = []
            AssignedSection.all(:article_id => v.article_id).each do |as|
              section_path = Section.get(as.section_id).path
              section_paths << section_path unless section_path.blank?
            end
            
            if section_paths.length != 1
              puts "Sections error: #{article.permalink}:#{article.id} - #{section_paths.length} sections: #{section_paths.join(' ;')}"
            end
            section = section_paths[0]
            
            commit_type = v.version == 1 ? "Create" : "Update"
            tags = []
            MephistoTagging.all(:taggable_id => v.article_id.to_i, :taggable_type => 'Content').each do |tagging|
              # repository(:mephisto) { MephistoTagging.all }
              if site_id == 2
                tags << MephistoTag.get(tagging.tag_id).name.downcase
              else
                tags << MephistoTag.get(tagging.tag_id).name
              end
            end
            tags = tags.join('; ')
            
            revision(rev += 1,
                "#{commit_type} article: #{section}/#{article.permalink} (Wistle Migration)",
                :author => 'jmorgan', #TODO: real name
                :date => v.updated_at
              ) do
  
              dir 'trunk' do
                dir 'articles' do
                  dir section do
                    file "#{article.permalink}.txt" do
                      # Ensure we are using the latest data.
                      v = article if v.version == article.version
                      
                      prop 'ws:title', v.title
                      filter = v.filter.gsub('_filter', '').camel_case
                      filter = "Smartypants; Markdown" if filter == "Smartypants"
                      filter = "Smartypants; Markdown" if filter == "Blank"
                      filter = "BibleML" if filter == "Bible"
                      prop('ws:filters', filter) unless filter.blank?
                      prop('ws:tags', tags) unless tags.blank?
                      if v.published_at
                        prop 'ws:published_at', v.published_at.strftime("%Y-%m-%d %H:%M:%S")
                      end
                      body v.body
                    end
                    
                  end
                end # dir
              end #trunk
            end # revision
            
          end
        end
      end
      
      svn_repo(@name).create.commit
      return true
    end
    
    def comments
      site_id = @site_id
      
      repository(:mephisto) do
        comments = Content.all(:site_id => site_id, :type => 'Comment', :order => [:created_at.asc])
        ary = []
        
        comments.each do |c|
          ary << {
            :author => c.author,
            :email => c.author_email,
            :body => c.body,
            :created_at => c.created_at,
            :updated_at => c.updated_at,
            :published_at => c.published_at,
            :article => Content.get(c.article_id).permalink
          }
        end
        File.open("#{site_id}.yml", 'w') {|f| f.write(ary.to_yaml) }
      end
    end
    
    def fix_site_ids
      repository(:mephisto) do 
        Content.all( :type => 'Article').each do |content|
          ContentVersion.all(:article_id => content.id).each do |cv|
            if cv.site_id != content.site_id
              puts "#{content.id}: #{cv.id} (#{content.site_id}) - #{content.permalink}"
              cv.update_attributes(:site_id => content.site_id)
            end
          end
        end
      end
      true
    end
  end
end

# load 'lib/migrations/mephisto.rb'
# m = Migrations::Mephisto.new("repo1", 1)
