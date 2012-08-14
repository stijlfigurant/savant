class User
	include ActiveModel::Validations
	attr_accessor :email, :password

	validates :email, :presence => true, :format => { :with => /^.+@.+$/ }
	validates :password, :presence => true

	def initialize(attributes = {})
    	attributes.each do |name, value|
      		send("#{name}=", value)
    	end
  	end
  
  	def persisted?
    	false
  	end
end