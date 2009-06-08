class SentController < ApplicationController
  layout "logged_in"
  def index
    @messages = current_user.sent_messages.paginate(:all, :page => params[:page], :per_page => 15, 
      :order => "created_at DESC", :conditions => "removed IS NULL")
    #@messages = @messages.sort!{|a,b| b.created_at <=> a.created_at}
  end

  def show
    @message = current_user.sent_messages.find(params[:id])
  end

  def new
    if @admin
      @users = User.all(:conditions => ["login != ?", @admin.login])
    else
      @users = []
      @users << User.find_admin
      @users += current_user.friends if current_user.friends.size != 0
    end
    @message = current_user.sent_messages.build
  end
  
  def create
    @message = current_user.sent_messages.build(params[:message])
    if @message.save
      flash[:notice] = "Message sent."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def delete_messages
    if params[:message_ids]
      @messages = current_user.sent_messages.find(params[:message_ids])
      for message in @messages
        message_copy = MessageCopy.find_by_message_id(message.id, :first)
        if message_copy !=  nil
          message.removed = 1 ## message(table Messages) set removed = 1 deleted by author, still visible by the recipient
          message.save
        else
          message.destroy 
        end
      end
    end
    redirect_to :action => "index"
  end
end