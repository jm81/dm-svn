require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Comment do

  before(:each) do
    Site.all.each { |s| s.destroy }
    Article.all.each { |a| a.destroy }
    Comment.all.each { |c| c.destroy }
    @comment = Comment.new
    @comment.author = "Jane Doe"
    @comment.body = "This post was foolish"
    @site = Site.create(:name => 'site')
    @article = Article.create(:site_id => @site.id)
    @comment.article_id = @article.id
  end
  
  def comment(parent_id = nil)
    c = Comment.new
    c.author = "Author"
    c.body = "A comment on Comment #{parent_id}"
    c.parent_id = parent_id
    c.article_id = @article.id
    c.save
    return c
  end
  
  it "should be valid" do
    @comment.should be_valid
  end

  it "should require an author" do
    @comment.author = ''
    @comment.should_not be_valid
  end
  
  it "should require a body" do
    @comment.body = ''
    @comment.should_not be_valid
  end
  
  it "should validate email format" do
    @comment.email = nil
    @comment.should be_valid # Allow nil
    @comment.email = 'jane'
    @comment.should_not be_valid
    @comment.email = 'jane@example.com'
    @comment.should be_valid
  end
  
  it "should have an optional parent" do
    @comment.save
    @comment.parent.should be_nil
    parent = comment
    @comment.parent_id = parent.id
    @comment.save
    Comment[@comment.id].parent.id.should == parent.id
  end
  
  it "should have many replies" do
    @comment.save
    5.times do |i|
      comment(@comment.id)
      comment(@comment.id + 1)
    end
    
    Comment[@comment.id].should have(5).replies
  end
  
  it "should update updated_at time" do
    @comment.save
    u = @comment.updated_at
    u.should_not be_nil
    sleep(0.1)
    @comment.body = "New Body"
    @comment.save
    @comment.updated_at.should > u
  end
  
  it "should update created_at time only on create" do
    @comment.save
    c = @comment.created_at
    c.should_not be_nil
    @comment.body = "New Body"
    @comment.save
    @comment.created_at.should == c
  end
  
  it "should filter body to html" do
    @comment.body = "Howdy *folks*"
    @comment.filters = "Markdown"
    @comment.save
    @comment.html.should == "<p>Howdy <em>folks</em></p>\n"
  end

end