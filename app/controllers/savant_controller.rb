include SavantModule

class SavantController < ApplicationController
	def login
		if !session[:google_drive_session].nil?
			redirect_to(:action => 'dashboard')
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

	def dashboard
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
			clients = SavantModule.create_sheet(drive, SavantModule::CLIENTS_SHEET, spreadSheets)
			@projects = SavantModule.create_sheet(drive, SavantModule::PROJECTS_SHEET, spreadSheets).worksheets[0]
			@invoices = SavantModule.create_sheet(drive, SavantModule::INVOICES_SHEET, spreadSheets).worksheets[0]
			
			#logger.debug invoices.inspect
		else
			redirect_to(:action => 'login')
		end
	end

	def add_invoice
		@invoice = params[:invoice]

		if !@invoice.nil?
			logger.debug @invoice

			redirect_to(:action => 'dashboard')
		end
	end

	def add_project
		@project = params[:invoice]

		if !@project.nil?
			logger.debug @project

			redirect_to(:action => 'dashboard')
		end
	end

	def add_client
		if !@client.nil?
			logger.debug @client

			redirect_to(:action => 'dashboard')
		end
	end
end

