# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  skip_before_filter :admin_check
  #use auto-session-timeout
  auto_session_timeout_actions

  # render new.rhtml
  def new
    if !logged_in?
      redirect_to maps_path  
    else
      redirect_to users_path  
    end
  end
  #creates new user session
  def create
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      self.current_user.profile.update_attributes(:status => "online")
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      if User.admin(self.current_user)
        redirect_to admin_users_path
      else
        redirect_back_or_default('/')
      end
      flash[:notice] = "Logged-in successfully. Welcome to your profile <b>#{current_user.login}.</b>"
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      render :template =>"/users/login"
    end
  end
  #destroys the current user session
  def destroy
    self.current_user.profile.update_attributes(:status => "offline")
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "Incorrect Email/Password Combination. "
    flash.now[:notice] = "Login failed. "
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
