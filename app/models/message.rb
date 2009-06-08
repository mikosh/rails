class Message < ActiveRecord::Base
  belongs_to :author, :class_name => "User"
  has_many :message_copies
  has_many :recipients, :through => :message_copies
  before_create :prepare_copies
  
  #validations for Message model
  validates_presence_of     :subject, :message => "Subject is missing!"
  validates_length_of       :subject,    :within => 1..60, :message => "Subject should be 1 to 60 characters long!"
  validates_presence_of     :body, :message => "Message body is missing!"
  validates_length_of       :body,    :within => 1..450, :message => "Body should be 1 to 450 characters long!"
  
  attr_accessor :to #array of people to send to
  attr_accessible :subject, :body, :to
  
  
  #Function builds copies of created message for the recipient/s
  def prepare_copies
    return if to.blank?
    
    to.each do |recipient|
      recipient = User.find(recipient)
      message_copies.build(:recipient_id => recipient.id, :folder_id => recipient.inbox.id, :created_at => Time.now)
    end
  end
  
end