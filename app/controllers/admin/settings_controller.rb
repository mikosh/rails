class Admin::SettingsController < ApplicationController
  #before_filter :login_required, :except => [:new, :create, :activate, :reset, :forgot]
  before_filter :admin_required
  layout "logged_in"
  def show
    redirect_to :action => 'edit'
  end
  def new
    redirect_to :action => 'edit'
  end
  def edit
    @settings = Settings.first
    
    if @settings.nil?
      flash[:notice] = "inside"
      @settings = Settings.new(:space => 500, :user_space => 10)
      @settings.save
    end
  end

  def update
    @settings = Settings.first
    #calculate maxinmum albums un messages per user
    params[:max_albums] = (0.9 * params[:user_space].to_i / 1.8).to_i
    params[:max_messages] = (0.1 * params[:user_space].to_i / 0.0005).to_i
    respond_to do |format|
      if @settings.update_attributes(:space => params[:space], :user_space => params[:user_space],
        :max_photos => params[:max_photos], :photo_size => params[:photo_size], :max_albums => 
        params[:max_albums], :max_messages => params[:max_messages])
        format.html { redirect_to(admin_users_path()) }
        format.xml  { head :ok }
        flash[:notice] = params.to_s
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @settings.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def calculate
    @settings = Settings.first
    unless params[:calc].blank?
      @settings.max_albums = 0.9 * params[:calc].to_i / 1.8 #15 photos * 120KB ~= 1800KB
      @settings.max_messages = 0.1 * params[:calc].to_i / 0.0005 # 1 message ~= 500B
    end
    render :partial =>'calculate'
  end
end
