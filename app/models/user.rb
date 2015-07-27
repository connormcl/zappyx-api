class User < ActiveRecord::Base
  require 'auth_token.rb'

  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: { in: 6..30 }, :on => :create

  def generate_auth_token
    payload = { user_id: self.id }
    AuthToken.encode(payload)
  end

  def self.find_by_credentials(email, password)
    user = User.find_by email: email
    if user && user.authenticate(password)
      return user
    else
      return nil
    end
  end
end
