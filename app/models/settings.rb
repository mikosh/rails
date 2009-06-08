class Settings < ActiveRecord::Base
  validates_presence_of :space, :message => "Server space is missing."
  validates_presence_of :user_space, :message => "Available user space is missing."
  validates_numericality_of :space, :message => "Only numbers are allowed."
  validates_numericality_of :user_space, :greater_than_or_equal_to => 10,
  :message => "Only numbers greater or equal than 10 are allowed."
end
