# Methods used by both Site and Category to access descendent articles.

module ArticleAncestor
  
  # Get published articles. Options include :year, :month, and :day for getting
  # published by a given date.
  def published_articles(options = {})
    year, month, day = options.delete(:year), options.delete(:month), options.delete(:day)
    # explicit options[:published] => false ????
    dt =  Time.parse("#{year}-#{month || 1}-#{day || 1}").strftime("%Y-%m-%d")
    pub = "datetime(published_at) <= datetime('now') "

    if day
      c = [pub + "and strftime('%Y-%m-%d', published_at) = strftime('%Y-%m-%d', ?)", dt]
    elsif month
      c = [pub + "and strftime('%Y-%m', published_at) = strftime('%Y-%m', ?)", dt]
    elsif year
      c = [pub + "and strftime('%Y', published_at) = strftime('%Y', ?)", dt]
    else # All published articles
      c = [pub]
    end
  
    def (c[0]).name; "noname"; end;
  
    options = {
        :conditions => c,
        :order => [:published_at.desc, :svn_name.asc]
      }.merge(options)
    
    # Surely, there is a better way..
    all = self.descendant_articles(options)
    sorted = all.sort{|a, b| b.published_at <=> a.published_at}
    
    sorted.instance_variable_set(:@pages, all.pages)
    sorted.instance_variable_set(:@current_page, all.current_page)
    def sorted.pages; @pages; end
    def sorted.current_page; @current_page; end  
    
    sorted
  end
  
  
  def descendant_articles(options)
    all = self.articles.all(options)
    
    if self.respond_to?(:children)
      self.children.each do |child|
        all += child.descendant_articles(options)
      end
    end
    
    return all
  end
end