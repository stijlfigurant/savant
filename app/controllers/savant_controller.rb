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
			@clients = SavantModule.create_sheet(drive, SavantModule::CLIENTS_SHEET, spreadSheets).worksheets[0]
			@projects = SavantModule.create_sheet(drive, SavantModule::PROJECTS_SHEET, spreadSheets).worksheets[0]
			@invoices = SavantModule.create_sheet(drive, SavantModule::INVOICES_SHEET, spreadSheets).worksheets[0]
			
			#logger.debug invoices.inspect
		else
			redirect_to(:action => 'login')
		end
	end

	def add_invoice
		drive = session[:google_drive_session]

		# fill in possible projects
		projectsSheet = SavantModule.get_sheet(drive, SavantModule::PROJECTS_SHEET).worksheets[0]
		projectsArray = SavantModule.worksheet_to_array(projectsSheet, SavantModule::PROJECTS_HASHARRAY)
		@projectsOptions = {}
		
		for project in projectsArray
			@projectsOptions[project["name"]] = project["id"]
		end

		# get worksheet
		worksheet = SavantModule.get_sheet(drive, SavantModule::INVOICES_SHEET).worksheets[0]

		# get new id
		@new_id = SavantModule.get_new_id(worksheet)

		if !params[:invoice].nil?

			params[:invoice]["id"] = @new_id
			SavantModule.insert_values(worksheet, params[:invoice], SavantModule::INVOICES_HASHARRAY)

			redirect_to(:action => 'dashboard')
		end
	end

	def add_project
		drive = session[:google_drive_session]

		# fill in possible clients
		clientsSheet = SavantModule.get_sheet(drive, SavantModule::CLIENTS_SHEET).worksheets[0]
		clientsArray = SavantModule.worksheet_to_array(clientsSheet, SavantModule::CLIENTS_HASHARRAY)
		@clientsOptions = {}
		
		for client in clientsArray
			@clientsOptions[client["name"]] = client["id"]
		end

		# get worksheet
		worksheet = SavantModule.get_sheet(drive, SavantModule::PROJECTS_SHEET).worksheets[0]

		# get new id
		@new_id = SavantModule.get_new_id(worksheet)

		if !params[:project].nil?
						
			params[:project]["id"] = @new_id
			SavantModule.insert_values(worksheet, params[:project], SavantModule::PROJECTS_HASHARRAY)
			
			redirect_to(:action => 'dashboard')
		end
	end

	def add_client
		drive = session[:google_drive_session]
		
		# get worksheet
		worksheet = SavantModule.get_sheet(drive, SavantModule::CLIENTS_SHEET).worksheets[0]

		# get new id
		@new_id = SavantModule.get_new_id(worksheet)

		if !params[:client].nil?

			params[:client]["id"] = @new_id
			SavantModule.insert_values(worksheet, params[:client], SavantModule::CLIENTS_HASHARRAY)

			redirect_to(:action => 'dashboard')
		end
	end
end

