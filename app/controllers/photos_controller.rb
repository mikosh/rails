class PhotosController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  def show
    @user = User.find(params[:user_id])
    @comment = Comment.new
    @photo = Photo.find(params[:id])
     
    @album = Album.find(@photo.album_id)
    @previous = @photo.previous
    @next  = @photo.next_photo
    count = 1
    @album.photos.each do |p|
      if p.id != @photo.id 
        count+=1
      else
        @photo_number = count
        break
      end
    end
    @location = Location.find_by_photo_id(@photo.id)
    if @location
      @map = GMap.new("map")
      @map.control_init(:large_map => false, :map_type => false)
      @map.center_zoom_init([@location.lat,@location.lng],0)
      @marker = GMarker.new([@location.lat,@location.lng])
      @map.overlay_init(@marker)
    else
      @location = Location.new 
    end 
  end
  def edit
     @album = Album.find(params[:album_id])
     @photo = Photo.find(params[:id])
  end

  def update
    @album = Album.find(params[:album_id])
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(params[:photo])
        flash[:notice] = 'Photo was successfully updated.'
        redirect_to user_album_photo_path(@album.user_id, @album, @photo) 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @album = Album.find(params[:album_id])
    @photo = Photo.find(params[:id])
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to user_album_path(@user.id, @album.id) }
    end
  end
end