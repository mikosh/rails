class Location < ActiveRecord::Base
    belongs_to :photo
  validates_length_of   :name, :within => 1..40
  validates_uniqueness_of :name
  validates_presence_of :name, :lat, :lng

  def find_by_address(address)
    @loc = Geokit::Geocoders::GoogleGeocoder.geocode(address)
    if @loc.success 
      @loc
    else 
      nil
    end
  end
end
