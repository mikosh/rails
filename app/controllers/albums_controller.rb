class AlbumsController < ApplicationController
  layout "logged_in"
  def index
    @user = User.find(params[:user_id])
    @photos = Photo.paginate_by_user_id(@user.id, :page => params[:page], :per_page => 20)
    #@photos = Photo.find_all_by_user_id(@user)
    @albums = Album.paginate_by_user_id(@user.id, :page => params[:page], :per_page => 10)
    
    return if @albums == nil
  end
  def new
    #@user = User.find(params[:user_id])
    @album = Album.new
    #@photo = Photo.new
    @album.photos.build
    #if @user.id != current_user.id
    #  redirect_to user_path(current_user)
    #end
  end
  def show
    @user = User.find(params[:user_id])
    @album = Album.find(params[:id])
  end
  
  def create
    @album = Album.new(params[:album])
    @album.user_id = current_user.id
    if @album.save
      flash[:notice] = "Successfully created album."
      redirect_to user_albums_path(current_user)
    else
      flash[:notice] = "Album can not be created."
      render :action => 'new'
    end
  end
  
  def edit
    @settings = Settings.find(1)
    @user=User.find(params[:user_id])
    @album = Album.find(params[:id])
    if (@user.id != current_user.id)
      redirect_to :action=>'show'
    end
  end
  
  def update
    @user=User.find(params[:user_id])
    @album = Album.find(params[:id])
    if @album.update_attributes(params[:album])
      flash.now[:notice] = "Successfully updated album."
      redirect_to :action=> 'edit'
    else
      flash[:notice] = "Allowed are only image files smaller than 3MB. Album can not be updated."
      redirect_to :action=> 'edit'
    end
  end
  def destroy
    #@user = User.find(current_user)
    @album = Album.find(params[:id])
    @album.destroy
    respond_to do |format|
      format.html { redirect_to user_albums_path }
    end
  end

end