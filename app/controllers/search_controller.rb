class SearchController < ApplicationController
  layout "logged_in"
  def index
    @user = User.find(current_user)
    if params[:search]
      @users = User.search(params[:search])
      params[:search] = ""
    else
      @users = User.extended_search(params)
    end
  end
  
end
