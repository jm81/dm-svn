SvnFixture::repo('news_site') do
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
  
  revision(2, 'Create categories',
      :date => Time.parse("2008-08-02")) do
    dir 'articles' do
      dir 'sports' do
        prop 'ws:name', 'Sports'
      end
      
      dir 'politics' do
        prop 'ws:name', 'Politics'
      end
    end
  end
  
  revision(3, 'Add two articles',
      :date => Time.parse("2008-08-03")) do
    dir 'articles' do
      dir 'sports' do
        file 'football.txt' do
          prop 'ws:title', 'Football'
          prop 'ws:published_at', '2008-08-04 12:00:00'
          body "A football story."
        end
      end
      
      dir 'politics' do
        file 'election.txt' do
          prop 'ws:title', 'Election Review'
          prop 'ws:published_at', '2008-08-04 12:00:00'
          body "The election seems to go on for a long time."
        end
      end
    end
  end
end

SvnFixture.repo('news_site').commit
