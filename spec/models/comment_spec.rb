require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Comment do

  before(:each) do
    clean Site, Category, Article, Comment
    @article = setup_article
    @article.path = "category/article"
    @comment = @article.comments.create({
        :author => 'Jane Doe', :body => 'My comments'})
  end
  
  def comment(parent_id = nil)
    @article.comments.create({
      :author => 'Author',
      :body => "A comment on Comment #{parent_id}",
      :parent_id => parent_id
    })
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
    Comment.get(@comment.id).parent.id.should == parent.id
  end
  
  it "should have many replies" do
    @comment.save
    5.times do |i|
      comment(@comment.id)
      comment(@comment.id + 1)
    end
    
    Comment.get(@comment.id).should have(5).replies
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
  
  it 'should have access to article path' do
    @comment.save
    @comment.article.path.should == @article_path
  end
  
  it 'should store article path' do
    @comment.save
    @comment.stored_article_path.should be_nil
    @comment.store_article_path
    @comment.stored_article_path.should == @article_path
    @comment.site_id.should == @article.site.id
  end
  
  it 'should reassociate to an article' do
    new_article = setup_article(@article.site)
    new_article.update_attributes(:svn_name => 'path/to/second')
    @comment.site_id = @article.site.id
    @comment.stored_article_path = @article_path
    @comment.save
    @comment.article = new_article
    @comment.save
    @comment.article.should be(new_article)
    @comment.reassociate_to_article.should be(true)
    @comment.article_id.should == @article.id

    @comment.update_attributes(:stored_article_path => 'no/article/path')
    @comment.reassociate_to_article.should be(false)
    @comment.article_id.should == @article.id
  end

end