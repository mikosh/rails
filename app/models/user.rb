require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles
 
  has_many :friends, :through => :friendships, :conditions => "status = 'accepted'"
  has_many :requested_friends, :through => :friendships, :source => :friend,
           :conditions => "status = 'requested'", :order => "friendships.created_at"
  has_many :pending_friends, :through => :friendships, :source => :friend,
           :conditions => "status = 'pending'", :order => "friendships.created_at"
  has_many :friendships, :dependent => :destroy
      
  has_many :sent_messages, :class_name => "Message", :foreign_key => "author_id"
  has_many :received_messages, :class_name => "MessageCopy", :foreign_key => "recipient_id"
  has_many :folders, :dependent => :destroy
  has_many :comments
  has_many :albums, :dependent => :destroy
  has_many :photos, :through => :albums
  has_one :wall, :dependent => :destroy
  has_one :profile, :dependent => :destroy
  
  after_create :build_account
  
  def inbox
    folders.find_by_name("Inbox")
  end
  #Builds user account, when created
  def build_account
    @folder = Folder.new(:user_id => self.id, :name => "Inbox")
    @folder.save 
    @wall = Wall.new(:user_id => self.id, :title => "Wall")
    @wall.save
    @album = Album.new(:user_id => self.id, :album_name => "Profile Album")
    @album.save
    @profile = Profile.new(:user_id => self.id)
    @profile.save
  end
  
  # User model validations
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message


  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation

  #random_password fucntion generates random(initial) user password 
  def self.random_password(size = 8)
    chars = (('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a) - %w(i o 0 1 l 0 O)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end
  #simple search function searches by login or name
  def self.search(search)
    if(search)
      find(:all, :conditions => ['login LIKE ? OR name LIKE ?', "%#{search}%", "%#{search}%"])
    end
  end
  #extended_search function can search user by many parameters
  def self.extended_search(params)
     query= [] #here go the SQL strings with "?" placeholders
     values= []#here go the values to be inserted in the strings of the query array
     #if params[:datestart]
     #   startdate = Date.strptime(params[:datestart], "%Y-%m-%d")
     #   enddate = Date.strptime(params[:dateend], "%Y-%m-%d")
     #query << " profiles.birthday between ? and ?" 
     #values << startdate
     #values << enddate
     #end
     if params[:login] && params[:login] != ""
       query << " users.login = ?"
       values << params[:login]
     end
     if params[:gender] && params[:gender] != "all"
       query << " profiles.gender = ?"
       values << params[:gender]
     end
     if params[:status] && params[:status] != "all"
       query << " profiles.status = ?"
       values << params[:status]
     end
     if params[:city] && params[:city] != ""
       query << " profiles.city = ?"
       values << params[:city]
     end
     if params[:country] && params[:country].to_s != "all"
       query << " profiles.country = ?"
       values << params[:country]
     end
    
     #conditions = [query.join(" AND "),values]
     conditions = []
     conditions << query.join(" AND ")
     conditions += values
  
     # should produce an array like:
     # ['profiles.birthday between ? and ? AND users.login = ?',startdate,enddate,params[:login]]
     #"SELECT * FROM users INNER JOIN profiles ON users.id = profiles.user_id WHERE"
     find(:all, :conditions => conditions, :include => [:profile])
  end
  #returns the mutual friends between the current user and a user's friend
  def mutual_friends_for(friend)
     self.friends & friend.friends
  end
  
  def create_reset_code
    @reset = true
    #Not working on Rails 2.0.2
    #self.update_attributes(:reset_code => Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join ))
    self.reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(false)
  end
  
  def recently_reset?
    @reset
  end
  
  def delete_reset_code
    self.reset_code = nil
    #self.update_attributes(:reset_code => nil)
    save(false)
  end

  # Authenticates a user by their email(login name) and unencrypted password.  Returns the user or nil.
  #
  #
  def self.authenticate(email, password)
    #returns nil if email or password is empty
    return nil if email.blank? || password.blank?
    #gets the first user from the database where state is active and email matches
    u = find_in_state :first, :active, :conditions => {:email => email} 
    # returns user object u if password matches or nil
    u && u.authenticated?(password) ? u : nil
  end
  

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def self.get_online_users
    sessions = CGI::Session::ActiveRecordStore::Session.find(:all, :conditions => ["updated_at >= ?", 15.minutes.ago])
    
    user_ids = sessions.collect{|s| s.data[:user_id]}.compact.uniq
    
    online_users = User.find(user_ids)
    
    return online_users
  end 


  
  protected
  
  def self.admin(user)
   (user.email == "threesixtybg@gmail.com")? user : nil
  end
  
  def self.find_admin
    User.find(:first, :conditions => {:email => "threesixtybg@gmail.com"})
  end
  
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end  
    
end
