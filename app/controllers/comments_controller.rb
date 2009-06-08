class CommentsController < ApplicationController
  layout "logged_in"
  def index
    @comments = Comment.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  def show
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end


  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  def edit
    @comment = Comment.find(params[:id])
    @wall = Wall.find(@comment.wall_id)
    
  end
  
  def reply
    @original = Comment.find(params[:id])
    @users = []
    @users << User.find(@original.user_id)
    subject = @original.title.sub(/^(Re: )?/, "Re: ")
    body = @original.comment.gsub(/^/, "> ")
    @message = current_user.sent_messages.build(:to => [@original.user_id], :subject => subject, :body => body)
    render :template => "sent/new"
  end
  
  def create
    params[:comment][:user_id] = current_user.id
    params[:comment][:commentable_id] = params[:commentable_id]
    params[:comment][:commentable_type] = params[:commentable_type]
    @comment = Comment.new(params[:comment])
    respond_to do |format|
      if !@comment.comment.empty? && @comment.save
        #flash[:notice] = params[:comment]
        format.html { redirect_to :back }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        if @comment.comment.empty?
          flash[:error] = "Comment is empty."
        elsif @comment.comment.size > 450
          flash[:error] = "Comment is too long."
        else
          flash[:error] = "Unknown error."
        end
        format.html { redirect_to :back }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(:controller => 'posts', :action => 'show', :id => @comment.post_id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(user_path(current_user)) }
      format.xml  { head :ok }
    end
  end
end
