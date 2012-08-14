include SavantModule

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
		drive = session[:google_drive_session]

		if !drive.nil?
			
			# TODO: Move all this into SavantModule
			# get root collection
			rootCollection = drive.root_collection			

			# check if has the "Savant"  collection
			savantCollection = rootCollection.subcollection_by_title(SavantModule::SAVANT)
			spreadSheets = nil

			# if it doesnt exist, create it
			if savantCollection.nil?
				savantCollection = rootCollection.create_subcollection(SavantModule::SAVANT)

				# create subcollections
				savantCollection.create_subcollection(SavantModule::TEMPLATES)
				savantCollection.create_subcollection(SavantModule::INVOICES)
				spreadSheets = savantCollection.create_subcollection(SavantModule::SPREADSHEETS)
			end

			# get spreadsheets subcollection
			if spreadSheets.nil?
				spreadSheets = savantCollection.subcollection_by_title(SavantModule::SPREADSHEETS)
			end

			# create spreadsheets
			SavantModule.create_sheet(drive, SavantModule::CLIENTS_SHEET, spreadSheets)
			SavantModule.create_sheet(drive, SavantModule::PROJECTS_SHEET, spreadSheets)
			SavantModule.create_sheet(drive, SavantModule::INVOICES_SHEET, spreadSheets)
			

		else
			redirect_to(:action => 'login')
		end
	end
end

