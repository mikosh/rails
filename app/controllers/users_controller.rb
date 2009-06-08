class UsersController < ApplicationController
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :login_required, :except => [:new, :create, :activate, :reset, :forgot]
  layout :check_layout
  
  def index
    #redirects to admin section if @admin logged in
    redirect_to admin_users_path if @admin 
    @user = User.find(current_user)
    @online_users = User.get_online_users
    #@friend = @user.friends[1]
    #@mutual_friends = @user.mutual_friends_for(@friend)
    
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
  
  # render new.rhtml
  def new
    redirect_to :action => :index
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.register! if @user && @user.valid? 
    success = @user && @user.valid?
    if success && @user.errors.empty?
      #redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.<br/>Please try again, or contact an admin."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash.now[:notice] = "Signup complete! Please sign in to continue."
      render :template =>"/users/login"
    when params[:activation_code].blank?
      flash.now[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash.now[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end
  def change
    flash.now[:notice] = "Pick up a new password."
    @user = User.find(current_user)
    if @user && request.post? && !(params[:user][:password].blank? && params[:user][:password_confirmation].blank?)
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        flash.now[:notice] = "Your password has been changed. You can now login."
        redirect_to user_path(@user)
      else
        flash.now[:notice] = "Password can't be reseted. Please make sure your password match with confirm  password."
        render :action => :change
      end
    end
    
  end
  def forgot
    if request.post?
      user = User.find_by_email(params[:user][:email])
      if user
        user.create_reset_code
        flash.now[:notice] = "Reset code sent to #{user.email}"
        render :template =>"/users/login"
      else
        flash.now[:notice] = "#{params[:user][:email]} does not exist in system"
      end
      #redirect_back_or_default('/')
    end
  end
  
  def reset
    @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if @user && request.post? && !(params[:user][:password].blank? && params[:user][:password_confirmation].blank?)
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        self.current_user = @user
        @user.delete_reset_code
        flash.now[:notice] = "Your password has been changed. You can now login."
        logout_keeping_session!
        render :template =>"/users/login"
      else
        flash.now[:notice] = "Password can't be reseted. Please make sure your password match with confirm  password."
        render :action => :reset
      end
    end
  end
  
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

protected

  def check_layout
    if logged_in? 
      if current_user.state == 'active' 
        "logged_in" 
      else
        "map"
      end
    else
      "map"
    end
  end
end
