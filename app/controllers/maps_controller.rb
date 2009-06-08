class MapsController < ApplicationController

  layout "map"
  def index
      
  end

  def addMarkers
    @locations = Location.all
    id = []
    lat = []
    lng = []
    photo_path = []
    title = []
    info = []
    @locations.each do |l|
       @photo = Photo.find(l.photo_id)
       @user = User.find(@photo.user_id)
        id  << l.photo_id
        lat << l.lat
        lng << l.lng
        photo_path << @photo.public_filename(:small)
        title << l.name
        info << "<h3>#{l.name}</h3><div id='map-thumb'><a href=#{user_album_photo_path(@photo.user_id, @photo.album_id, @photo.id)}>
                        <img src=#{@photo.public_filename()}></img></a></div><p>By <a href=#{user_path(@user)}>#{@user.name}</a></p>"
    end
        render :update do |page|
          page << "addM(#{id.to_json}, #{lat.to_json}, #{lng.to_json}, #{photo_path.to_json}, #{title.to_json}, #{info.to_json});"
        end    
  end
  
  def search
    #@location = GoogleGeocoder.geocode(address)
    @locations = Geocoding::get(params[:search])
    if @locations.status == Geocoding::GEO_SUCCESS
      render :update do |page|
        page.replace_html 'results', :partial => 'results'
        page << "focusPoint(#{@locations.first.object_id}, #{@locations.first.latitude}, #{@locations.first.longitude}, #{@locations.first.address.to_json});"
      end
    else
      flash.now[:notice] = "No results found."
      render :update do |page|
          page.replace_html 'results', :partial => "errors"
      end
    end
  end
  
  def route
    @start = Geocoding::get(params[:start])
    @destination = Geocoding::get(params[:destination])
    if @start.status == Geocoding::GEO_SUCCESS && @destination.status == Geocoding::GEO_SUCCESS
       render :update do |page|
          page.replace_html 'results', ""
          page << "calculate_route(#{@start.first.latitude}, #{@start.first.longitude}, #{@destination.first.latitude}, #{@destination.first.longitude});"
       end
    else
      flash[:notice] = "No results found."
      render :update do |page|
          page.replace_html 'results', :partial => "errors"
      end
    end
  end
end
