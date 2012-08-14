class SavantController < ApplicationController
	def login
		if session[:token]
			render(:action => 'overview')
		end
	end

	def do_login
		@user = User.new(params[:user])
		if @user.valid?
			client_login_handler = GData::Auth::ClientLogin.new('writely', :account_type => 'HOSTED')
			token = client_login_handler.get_token(@user.email, @user.password, 'savant')
			client = GData::Client::Base.new(:auth_handler => client_login_handler)

			session[:token] = token
			session[:client] = client

			render(:action => 'overview')
		else
			render(:action => 'login')
		end
	end

	def overview

	end

	def all
		@foo = 'I pity the foo!'
	end
end

