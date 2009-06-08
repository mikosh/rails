class MailboxController < ApplicationController
  before_filter :login_required
  layout "logged_in"
  def index
    @folder = current_user.inbox
    show
    render :action => "show"
  end
  
  def show
    @folder ||= current_user.folders.find(params[:id])
    #@new_messages = @folder.messages.find(:all, :conditions => "read_at IS NULL")
    @messages = @folder.messages.paginate(:all, :page => params[:page], :per_page => 15, 
      :order => "created_at DESC")
  end
  
  def delete_messages
    @folder ||= current_user.folders.find(params[:id])
    if params[:message_ids]
      @messages = @folder.messages.find(params[:message_ids])
      for received_message in @messages
        sent_message = Message.find(received_message.message_id)
        received_message.destroy
        if (sent_message.removed == true)
          sent_message.destroy unless @folder.messages.find_by_message_id(sent_message.id)
        end
        
      end
    end
    redirect_to inbox_path
  end

end
