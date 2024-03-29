class User < ActiveRecord::Base
    #model relationships
    has_many :sales
    has_many :messages
    has_many :employees
    has_many :payrolls

    
    #data validation
	attr_accessor :remember_token, :activation_token
	before_save { self.email.downcase! }
    before_create :create_activation_digest
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 }, 
			  format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true


	# Returns the hash digest of the given string.
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
													  BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	# Returns a random token.
	def self.new_token
		SecureRandom.urlsafe_base64
	end


	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	# Returns true if the given token matches the digest.
	def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
	end

	# Forget a user.
	def forget
		update_attribute(:remember_token, nil)
	end
    
    def activate 
        update_attribute(:activated,    true)
        update_attribute(:activated_at, Time.zone.now)
    end
    
    def send_activation_email 
        UserMailer.account_activation(self).deliver_now
    end
    
    private
    def create_activation_digest 
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
    end
end
