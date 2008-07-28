module Merb
  module GlobalHelpers
    
    ##
    # Generate URL for a reply comment.
    # 
    # @param [Article, Comment] parent The parent of the comment (Article for
    #   direct comments).
    #
    # @raise [RuntimeError] if parent is unrecognized
    def reply_to(parent)
      if parent.is_a?(Article)
        url(:new_article_comment,
            :article_id => parent.id)
      elsif parent.is_a?(Comment)
        url(:new_article_comment,
            :article_id => parent.article_id,
            :parent_id => parent.id)
      else
        raise RuntimeError, "parent must be an Article or Comment"
      end
    end
    
    def article_url(article)
      "/#{article.path}"
    end
    
    def image_tag(img, opts ={})
      opts[:path] ||= "/sites/#{@site.name}/images/"
      super(img, opts)
    end
    
    def asset_path(asset_type, filename, local_path = false)
      path = super(asset_type, filename, local_path)
      "/sites/#{@site.name}#{path}"
    end
    
    def ads(path)
      partial("ads/#{path}") if Merb::environment == "production"
    end
  end
end
