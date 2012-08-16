class Client
	include ActiveModel::Validations
	attr_accessor :id, :name, :address_1, :address_2, :zip_code, :city, :country, :vat_no

	#validates :email, :presence => true, :format => { :with => /^.+@.+$/ }
	#validates :password, :presence => true

	def initialize(attributes = {})
  	attributes.each do |name, value|
    		send("#{name}=", value)
  	end
	end
  
	def persisted?
  	false
	end
end