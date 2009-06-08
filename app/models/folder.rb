class Folder < ActiveRecord::Base
  acts_as_tree #folders can contain other folders
  belongs_to :user
  has_many :messages, :class_name => "MessageCopy", :dependent => :destroy  
end