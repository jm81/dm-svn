require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Comment do

  before(:each) do
    Comment.all.each { |c| c.destroy }
    @comment = Comment.new
    @comment.author = "Jane Doe"
    @comment.body = "This post was foolish"
    @comment.article_id = 1
  end
  
  def comment(parent_id = nil)
    c = Comment.new
    c.author = "Author"
    c.body = "A comment on Comment #{parent_id}"
    c.parent_id = parent_id
    c.article_id = 1
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

end