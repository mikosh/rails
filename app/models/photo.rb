class Photo < ActiveRecord::Base
  acts_as_commentable
  belongs_to :album
  has_one :location, :dependent => :destroy
  
  #Photo model uses Rmagick image processor to resize photos, create thumbs
  has_attachment :content_type => :image,
    :size => 0.megabyte..3.2.megabytes,
    :storage => :file_system,
    :processor => 'Rmagick',
    :resize_to => '450x450',
    :thumbnails => {:thumb => 'thumb: 90x90>', :small => 'crop: 30x30>'}
  
  #validations for Photo model
  validates_as_attachment
  attr_accessible :should_destroy, :description, :uploaded_data
  attr_accessor :should_destroy 
  
  # check if photo should be deleted 
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  #previous method returns the previous photo in album
  def previous
    Photo.find(:first, :order=> "id DESC", :conditions => ["id < ? AND album_id = ? AND user_id = ?", id, album_id, user_id])
  end
  
  #next_photo method return the next photo in album
  def next_photo
    Photo.find(:first, :conditions => ["id > ? AND album_id = ? AND user_id = ?", id, album_id, user_id])
  end
  
  protected  
  
  #Override image resizing method  
  def resize_image(img, size)  
    # resize_image take size in a number of formats, we just want  
    # Strings in the form of "crop: WxH"  
    
      if (size.is_a?(String) && size =~ /^crop: (\d*)x(\d*)/i) ||  
     (size.is_a?(Array) && size.first.is_a?(String) &&  
      size.first =~ /^crop: (\d*)x(\d*)/i)
        img.crop_resized!($1.to_i, $2.to_i) 
        img.border!(2,2,'white') 
        self.temp_paths.unshift write_to_temp_file(img.to_blob) 
      elsif (size.is_a?(String) && size =~ /^thumb: (\d*)x(\d*)/i) ||  
     (size.is_a?(Array) && size.first.is_a?(String) &&  
      size.first =~ /^thumb: (\d*)x(\d*)/i)
        img.resize!(0.20)
        img.border!(4,4,'white') 
        self.temp_paths.unshift write_to_temp_file(img.to_blob)
    #if (size.is_a?(String) && size =~ /^crop: (\d*)x(\d*)/i) ||  
     #(size.is_a?(Array) && size.first.is_a?(String) &&  
      #size.first =~ /^crop: (\d*)x(\d*)/i)  
      #img.crop_resized!($1.to_i, $2.to_i) 
      #img.border!(2,2,'white') 
      # We need to save the resized image in the same way the  
      # orignal does. 
      #self.temp_paths.unshift write_to_temp_file(img.to_blob) 
     # self.temp_path = write_to_temp_file(img.to_blob)  
    else 
      
      super # Otherwise let attachment_fu handle it 
      #img.border!(5,5,'white')  
    end  
  end   
end