require 'digest/sha1'

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :email
  validates_presence_of     :password,                   :if => :password_required?
#  validates_presence_of     :password_confirmation,      :if => :password_required?
#  validates_length_of       :password, :within => 4..40, :if => :password_required?
#  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => true
  attr_accessible 					:email, :password, :salt, :hint, :password_confirmation
  before_save :encrypt_password
  attr_accessor :password_confirmation
  
  has_many :posts, :order => 'created_at DESC'

	
  def self.authenticate(login, password)
    u = find_by_email(login) # need to get the salt
    u = u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    encrypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 4.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
		self.save
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{password}--") if new_record?
      self.encrypted_password = encrypt(password)
    end
    
    def password_required?
      encrypted_password.blank? || !password.blank?
    end
    
end
