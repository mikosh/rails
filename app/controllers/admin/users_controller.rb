class Admin::UsersController < ApplicationController
  # Protect these actions behind an admin login
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :admin_required
  layout "logged_in"
  
  def index
    @settings = Settings.first
    @settings = Settings.new if !@settings
    @users = User.find(:all, :conditions =>["login != ?", @admin.login])
    @online_users = User.get_online_users  
  end
  
  def show
    @user = User.find(params[:id])
    @profile = Profile.find_by_user_id(@user.id)
    @wall= Wall.find_by_user_id(@user.id)
    @comment=Comment.new
    respond_to do |format|
       format.html { }
       format.xml  { head :ok }
       format.js
    end
  end 

  def new
    @random_password = User.random_password(8)
    @user = User.new
  end
 
  def create
    @user = User.new(params[:user])
    @user.register! if @user && @user.valid? 
    success = @user && @user.valid?
    if success && @user.errors.empty?
      redirect_to admin_users_path()
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      @random_password = User.random_password(8)
      render :action => 'new'
      flash[:error]  = "Account could not be created."
      
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      #redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end
  
  def forgot
    if request.post?
      user = User.find_by_email(params[:user][:email])
      if user
        user.create_reset_code
        flash[:notice] = "Reset code sent to #{user.email}"
      else
        flash[:notice] = "#{params[:user][:email]} does not exist in system"
      end
      #redirect_back_or_default('/')
    end
  end
  
  def reset
    @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        self.current_user = @user
        @user.delete_reset_code
        flash[:notice] = "Password reset successfully for #{@user.email}"
        logout_keeping_session!
      else
        render :action => :reset
      end
    end
  end
  
  def suspend
    @user.suspend! 
    redirect_to admin_users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to admin_users_path
  end

  def destroy
    @user.delete!
    redirect_to admin_users_path
  end

  def purge
    @user.destroy
    redirect_to admin_users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

  
protected
  def find_user
    @user = User.find(params[:id])
  end
  def check_layout
    logged_in? && @user.state == 'active' ? "logged_in" : "not_logged_in"
  end
end
