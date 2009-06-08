class Album < ActiveRecord::Base
  belongs_to :user
  has_many :photos, :dependent => :destroy
  
  #validations for Album model
  validates_presence_of :album_name
  
  #validates_associated :photos
  
  # save_images is called if album is created or updated
  after_create :save_images
  after_update :save_images
  
  def image_attributes=(image_attributes)
    image_attributes.each do |attributes|
      if attributes[:id].blank?
        photos.build(attributes)
      else
        photo = photos.detect { |t| t.id == attributes[:id].to_i}
        photo.id = attributes[:id]
        attributes.delete("id")
        photo.attributes = attributes
      end
    end
  end
  
  #method saves or deletes images
  def save_images
    photos.each do |image|
      if image.should_destroy?
        image.destroy
      else
        if (!image.user_id) 
          image.user_id = self.user_id
        end
        image.save(false)
      end
    end
  end
end