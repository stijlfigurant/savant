class SavantController < ApplicationController
	def login

	end

	def do_login
		@user = User.new(params[:user])
		@user.valid?
		
		render(:action => 'login')
	end

	def all
		@foo = 'I pity the foo!'
	end
end

