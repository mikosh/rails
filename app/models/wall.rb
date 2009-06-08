class Wall < ActiveRecord::Base
  acts_as_commentable
  
  belongs_to :user
  
  #validations of Wall model
  validates_length_of :title, :within => 3..40, :message => "Wall title should be 3 to 40 characters long!"
end
