class SavantController < ApplicationController
	def login
		if !session[:google_drive_session].nil?
			render(:action => 'overview')
		end
	end

	def do_login
		@user = User.new(params[:user])
		if @user.valid?
			session[:google_drive_session] = GoogleDrive.login(@user.email, @user.password)
			logger.debug session.inspect
		end

		redirect_to(:action => 'login')
	end

	def logout
		reset_session
		
		redirect_to(:action => 'login')
	end

	def overview

	end

	def all
		@foo = 'I pity the foo!'
	end
end

