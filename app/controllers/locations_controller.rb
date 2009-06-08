class LocationsController < ApplicationController
  include Geokit::Geocoders
  include Geokit::Mappable

  def new
    @location = Location.new
  end
  
  def create
    @photo = Photo.find(params[:id])
    @loc = GoogleGeocoder.geocode(params[:address])
    if @loc.success
      @location = Location.new(:photo_id => @photo.id, :name => params[:name],
        :address => @loc.full_address, :city => @loc.city, :state => @loc.state,
        :zip => @loc.zip, :country => @loc.country_code, :lat => @loc.lat, :lng => @loc.lng)
        if  @location.save
          flash[:notice] = "Location saved."
        else
          flash[:notice] = "Location cannot be saved." 
        end

    else
      flash[:notice] = "Location cannot be found."
    end
    redirect_to(user_album_photo_path(@photo.user_id, @photo.album_id, @photo)) 
  end
  
  def update
    @loc = GoogleGeocoder.geocode(params[:address])
    if @loc.success
      @location = Location.find(params[:id])
      if @location.update_attributes(:name => params[:name],
        :address => @loc.full_address, :city => @loc.city, :state => @loc.state,
        :zip => @loc.zip, :country => @loc.country_code, :lat => @loc.lat, :lng => @loc.lng)
        flash[:notice] = "Photo location updated."
      else
        flash[:notice] = "Photo location cannot be updated."
      end
    else
      flash[:notice] = "Photo location not found."
    end
    redirect_to :back
  end
  
  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    flash[:notice] = "Photo removed from the map."
    redirect_to :back
  end
end
