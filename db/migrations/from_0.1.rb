require 'dm-migrations'

class From_0_1
  def self.run
    Article.property :path, String, :length => 255
      
    Article.repository.auto_upgrade!
    Article.all.each do |a|

      if a.svn_name.nil?
        a.svn_name = a.path
      end
      
      a.save
    end
  end
end

From_0_1.run
