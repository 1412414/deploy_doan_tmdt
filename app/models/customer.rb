class Customer < ApplicationRecord
	has_many :products
	has_many :complaints
	has_many :notifications
	has_many :reports
	has_many :reviews

	has_secure_password

	validates :username, :presence	=> true,
			  :uniqueness 		=> {:case_sensitive => false}

	#def self.authenticate!(session_params)
	#	customer = Customer.authenticate(session_params)

	#	if customer.nil?
	#		raise RecordNotFound
	#	else
	#		customer
	#	end
	#end

  # def self.authenticate(session_params)
  # 	user = User.find_by(email: session_params[:email])
  
  # 	if user.password == session_params[:password]
  # 		user
  # 	else
  # 		false
  # 	end
  # end

  	#def self.authenticate?(session_params)
  	#	!Customer.authenticate(session_params).nil?
  	#end
end
