class Comments < Application
  # provides :xml, :yaml, :js
  before :assign_article_and_parent

  def index
    redirect url(:article, @article)
  end

  def show
    @comment = @article.comments.first(:id => params[:id])
    raise NotFound unless @comment
    display @comment
  end

  def new
    only_provides :html
    @comment = Comment.new
    render
  end

  def create
    @comment = Comment.new(params[:comment])
    @article.comments << @comment
    @parent.replies << @comment if @parent
    if @comment.save
      redirect url(:article_comment,
          :article_id => @article.id,
          :comment_id => @comment.id)
    else
      render :new
    end
  end
  
  protected
  
  def assign_article_and_parent
    @article = Article.get(params[:article_id])
    raise NotFound unless @article
    @parent = Comment.get(params[:parent_id]) unless params[:parent_id].blank?
  end

end
