require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Article do
  
  before(:each) do
    Comment.all.each { |c| c.destroy }
    @article = Article.new
    @article.title = "First Post"
    @article.body = "Howdy folks"
    @article.save
  end
  
  def comment(article_id)
    c = Comment.new
    c.author = "Author"
    c.body = "A comment on Article #{article_id}"
    c.article_id = article_id
    c.save
    return c
  end

  it "should have many comments" do
    5.times do |i|
      comment(@article.id)
      comment(@article.id + 1)
      comment(@article.id + 2)
    end
    
    Article[@article.id].should have(5).comments
  end
  
  it "should have direct_comments" do
    5.times do |i|
      c = comment(@article.id)
      if i > 2
        c.parent_id = 1
        c.save
      end
    end
    
    Article[@article.id].should have(5).comments
    Article[@article.id].should have(3).direct_comments
  end

end