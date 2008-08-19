module Merb
  module PaginationHelper
    def pagination(collection, padding = 3)
      padding ||= 3
      partial("page_links", :collection => collection, :padding => padding)
    end
    
    def page_set(collection, padding = 3)
      first = [1, collection.current_page - padding].max
      last = [collection.pages, collection.current_page + padding].min

      leader = case first
        when 1 then []
        when 2 then [1]
        else [1, 0]
      end
      
      footer = case last
        when collection.pages then []
        when  collection.pages - 1 then [collection.pages]
        else [0, collection.pages]
      end
      
      leader + (first..last).to_a + footer
    end
    
  end
end
