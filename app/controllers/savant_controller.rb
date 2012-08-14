class SavantController < ApplicationController
	def login
		if !session[:google_drive_session].nil?
			redirect_to(:action => 'overview')
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
		if !session[:google_drive_session].nil?
			# get root collection
			rootCollection = session[:google_drive_session].root_collection			

			# check if has the "Savant"  collection
			savantCollection = rootCollection.subcollection_by_title("Savant")

			# if it doesnt exist, create it
			if savantCollection.nil?
				savantCollection = rootCollection.create_subcollection("Savant")

				# create subcollections
				savantCollection.create_subcollection("Templates")
				savantCollection.create_subcollection("Invoices")
				savantCollection.create_subcollection("Spreadsheets")
			end

			logger.debug savantCollection

		else
			redirect_to(:action => 'login')
		end
	end
end

