SvnFixture.repo('fiction_site') do
  revision(1, 'Create basic directory structure (including articles, app and public)',
      :date => Time.parse("2008-08-01")) do
    dir 'articles'
    dir 'app' do
      dir 'views' do
        dir 'ads'
        dir 'articles'
        dir 'layouts'
      end
    end
    
    dir 'public' do
      dir 'images'
      dir 'javascripts'
      dir 'stylesheets'
    end
  end
  
  revision(2, 'Create scifi, fantasy, and western categories',
      :date => Time.parse("2008-08-02")) do
    dir 'articles' do
      dir 'scifi' do
        prop 'ws:name', 'Science Fiction'
      end
      
      dir 'fantasy' do
        prop 'ws:name', 'Fantasy'
      end
      
      dir 'western' do
        prop 'ws:name', 'Western'
      end
    end
  end
  
  revision(3, 'Add two stories in scifi',
      :date => Time.parse("2008-08-03")) do
    dir 'articles' do
      dir 'scifi' do
        file 'aliens.txt' do
          prop 'ws:title', 'Alien Story'
          prop 'ws:published_at', '2008-08-04 12:00:00'
          body "My first story featuring aliens."
        end
        
        file 'spaceships.txt' do
          prop 'ws:title', 'Spaceship'
          prop 'ws:published_at', '2008-08-06 12:00:00'
          body "This one's just about spaceships."
        end
      end
    end
  end

  revision(4, 'Add scifi/alien subcategory and move aliens.txt there',
      :date => Time.parse("2008-08-04")) do
    dir 'articles' do
      dir 'scifi' do
        dir 'alien' do
          file 'meta.yml' do
            body "name: Alien Stories"
          end
        end
        
        move 'aliens.txt', 'alien/first.txt'
      end
    end
  end
  
  revision(5, 'Add unpublished fantasy story',
      :date => Time.parse("2008-08-06")) do
    dir 'articles' do
      dir 'fantasy' do
        file 'knights.txt' do
          prop 'ws:title', 'Knights'
          body "A story...with knights!"
        end
      end
    end
  end
end

SvnFixture.repo('fiction_site').commit
