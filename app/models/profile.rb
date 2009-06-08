class Profile < ActiveRecord::Base
  belongs_to :user
  
  # Return the age using the birthdate.
  def age(today = Date.today)
    return nil if self.birthday.nil? || self.birthday > today
    if (today.month > self.birthday.month) or 
       (today.month == self.birthday.month and today.day >= self.birthday.day)
      # Birthday has happened already this year.
      today.year - self.birthday.year
    else
      today.year - self.birthday.year - 1
    end
  end
end
