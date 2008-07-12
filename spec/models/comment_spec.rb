require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Comment do

  before(:each) do
    @comment = Comment.new
    @comment.author = "Jane Doe"
    @comment.body = "This post was foolish"
    @comment.article_id = 1
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

end