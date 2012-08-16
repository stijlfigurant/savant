class Project
	include ActiveModel::Validations
	attr_accessor :id, :name, :client, :status

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