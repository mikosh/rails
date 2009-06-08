class WallsController < ApplicationController
  before_filter :login_required

  def index
    @wall = Wall.find_by_user_id(current_user)
    if(@wall == nil)
      @wall = Wall.new(:title=> "Wall", :user_id => current_user.id)
      @wall.save
    end
    @comment = Comment.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @wall }
    end
  end

  def show
    @comment = Comment.new
    @wall = Wall.find_by_user_id(current_user)
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @wall }
    end
  end

  def new
    @wall = Wall.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wall }
    end
  end

  def edit
    @wall = Wall.find_by_user_id(current_user.id)
  end

  def create
    @wall = Wall.new(params[:wall])
    
    respond_to do |format|
      if @wall.save
        flash[:notice] = 'Wall was successfully created.'
        format.html { redirect_to(@wall) }
        format.xml  { render :xml => @wall, :status => :created, :location => @wall }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @wall.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @wall = Wall.find_by_user_id(current_user.id)

    respond_to do |format|
      if @wall.update_attributes(params[:wall])
        format.html { redirect_to(user_path(current_user)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wall.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @wall = Wall.find(params[:id])
    @wall.destroy

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end


end
