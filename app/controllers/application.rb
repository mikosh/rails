# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable
  local_addresses.clear
  #set auto-session-timeout time
  auto_session_timeout 15.minute

  helper :all # include all helpers, all the time
  before_filter :check_inbox
  before_filter :admin_check
  #alias_method :rescue_action_locally, :rescue_action_in_public #should be removed when not local

  layout "map"
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => 'd7f5a60296c99dd27d5bf88f652d0f75'
  session :session_key => '_app_session'
  #def rescue_action_in_public(exception)
  #  case exception
  #    when ActiveRecord::RecordNotFound, ::ActionController::UnknownController, ::ActionController::UnknownAction
  #      render  :file   => "#{RAILS_ROOT}/public/404.html",
  #      :status => "404 Not Found",
  #      :layout => true
  #    else
  #      render  :file   => "#{RAILS_ROOT}/public/500.html",
  #      :status => "500 Error",
  #      :layout => true
  #       Mailer.deliver_exception_notification(self, request, exception)
  #    end
  #end 

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  protected
  def check_inbox
    if current_user
      @folder ||= current_user.folders.find_by_name("Inbox")
      @new_messages = @folder.messages.find(:all, :conditions => "read_at IS NULL")
    end
  end
  
  def admin_check
    if current_user
      @admin = User.admin(current_user)
    end
  end
  
  def admin_required
     rescue_action_in_public(ActiveRecord::RecordNotFound) unless @admin
  end
end
