class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Activate your account'
    @body[:url]  = "Please click the link to activate your account http://sofiata.com/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "You can now log-in at http://sofiata.com/"
  end
  
  def reset_notification(user)
    setup_email(user)
    @subject    += 'Link to reset your password'
    @body[:url]  = "Please click the link to reset your password http://sofiata.com/reset/#{user.reset_code}"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "support <support@sofiata.com>"
      #headers    "Reply-to" => "noreply@site.example" 
      @subject     = "Sofiata.com "
      @sent_on     = Time.now
      @body[:user] = user
    end
end