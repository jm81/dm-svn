# This is a repository representing information for two models in one repo.

require File.dirname(__FILE__) + "/../../../lib/wistle/fixture.rb"

svn_repo('articles_comments') do
  revision(1, 'Create articles and comments directories',
      :date => Time.parse("2007-01-01")) do
    dir 'articles'
    dir 'comments'
  end
  
  revision 2, 'Create articles about computers and philosophy' do
    dir 'articles' do
      file 'philosophy.txt' do
        prop 'ws:title', 'Philosophy'
        prop 'ws:published_at', (Time.now - 2 * 24 * 3600) # 2.days.ago
        body 'My philosophy is to eat a lot of salsa!'
      end
      
      file 'computers.txt' do
        prop 'ws:title', 'Computers'
        prop 'ws:published_at', (Time.now - 1 * 24 * 3600) # 1.day.ago
        body 'Computers do not like salsa so much.'
      end      
    end
  end
  
  revision 3, 'Write unpublished Article', :author => "author" do
    dir 'articles' do
      file 'unpublished.txt' do
        prop 'ws:title', 'Private Thoughts'
        body "See, it's not published.\nYou can't read it."
      end
    end
  end
  
  revision 4, 'Decide to publish unpublished Article' do
    dir 'articles' do
      file 'unpublished.txt' do
        prop 'ws:published_at', (Time.now - 3600) # 1.hour.ago
      end
    end
  end
  
  revision 5, 'Update text of Computer article' do
    dir 'articles' do
      file 'computers.txt' do
        body 'Computers do not like salsa very much.'
      end
    end
  end
  
  revision 6, 'Add a couple of comments' do
    dir 'comments' do
      file 'computers_1.txt' do
        prop 'ws:article', 'computers.txt'
        body "They don't like most liquids"
      end
    end

    dir 'comments' do
      file 'computers_2.txt' do
        prop 'ws:article', 'computers.txt'
        body "OH, RLY?"
      end
    end
  end
  
  revision 7, 'Moves and copies' do
    dir 'articles' do
      move 'unpublished.txt', 'just_published.txt'
      copy 'computers.txt', 'computations.txt'
    end
  end
  
  revision 7, 'Delete computers.txt' do
    dir 'articles' do
      delete 'computers.txt'
    end
  end
end

svn_repo('articles_comments').create.commit