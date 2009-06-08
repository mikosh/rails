class ProfilesController < ApplicationController
  layout "logged_in"
  
  def edit
    @user = User.find(current_user)
    @profile = Profile.find_by_user_id(@user.id)
  end
  
  
  def update
    @profile=Profile.find_by_user_id(current_user)
    params[:profile][:gender] = nil if params[:profile][:gender] == "Select Sex:"
    params[:profile][:country] = nil if params[:profile][:country] == "Select Country:"
    respond_to do |format|
        if @profile.update_attributes(params[:profile])
          flash[:notice] = 'User Profile was successfully updated.'
          format.html { redirect_to(user_path(current_user)) }
          format.xml  { head :ok } 
          format.js{
            render :update, :partial do |page|
              page[:about_me].replace_html :partial => '/users/write'
            end
          }
        else
          flash.now[:notice] = 'User Profile cannot be updated.'
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  
  
end
