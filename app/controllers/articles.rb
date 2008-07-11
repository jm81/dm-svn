class Articles < Application
  # provides :xml, :yaml, :js

  def index
    @articles = Article.all
    display @articles
  end

  def show
    @article = Article.get(params[:id])
    raise NotFound unless @article
    display @article
  end

  def new
    only_provides :html
    @article = Article.new
    render
  end

  def edit
    only_provides :html
    @article = Article.get(params[:id])
    raise NotFound unless @article
    render
  end

  def create
    @article = Article.new(params[:article])
    if @article.save
      redirect url(:article, @article)
    else
      render :new
    end
  end

  def update
    @article = Article.get(params[:id])
    raise NotFound unless @article
    if @article.update_attributes(params[:article]) || !@article.dirty?
      redirect url(:article, @article)
    else
      raise BadRequest
    end
  end

  def destroy
    @article = Article.get(params[:id])
    raise NotFound unless @article
    if @article.destroy
      redirect url(:article)
    else
      raise BadRequest
    end
  end

end
