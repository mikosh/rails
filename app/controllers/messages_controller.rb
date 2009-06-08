class MessagesController < ApplicationController
  layout "logged_in"
  def show
    @message = current_user.received_messages.find(params[:id])
    @message.update_attributes(:read_at => Time.now)
  end
  
  def reply
    @original = current_user.received_messages.find(params[:id])
    @users = []
    @users << User.find(@original.author.id)
    subject = @original.subject.sub(/^(Re: )?/, "Re: ")
    body = @original.body.gsub(/^/, "> ")
    @message = current_user.sent_messages.build(:to => [@original.author.id], :subject => subject, :body => body)
    render :template => "sent/new"
  end
  
  def forward
    if @admin
      @users = User.all
    else
      @users = []
      @users << User.find_admin
      @users += current_user.friends if current_user.friends.size != 0
    end
    @original = current_user.received_messages.find(params[:id])
    
    subject = @original.subject.sub(/^(Fwd: )?/, "Fwd: ")
    body = @original.body.gsub(/^/, "> ")
    @message = current_user.sent_messages.build(:to => [nil], :subject => subject, :body => body)
    render :template => "sent/new"
  end
  
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html {  }
      format.xml  { head :ok }
    end
  end
  

end