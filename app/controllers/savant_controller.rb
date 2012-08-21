# encoding: utf-8

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

			# new invoice title = Invoice_id_projectid
			invoice_title = "Invoice_" + @new_id.to_s

			# create new invoice
			# get invoice template 
			savantCollection = SavantModule.get_collection(drive)
    		collection = savantCollection.subcollection_by_title(SavantModule::TEMPLATES)
			template = collection.files("title" => "Invoice", "title-exact" => "true")[0]

			# get client details
			project = SavantModule.hash_by_id(projectsArray, params[:invoice]["project"])
			
			clientsSheet = SavantModule.get_sheet(drive, SavantModule::CLIENTS_SHEET).worksheets[0]
			clientsArray = SavantModule.worksheet_to_array(clientsSheet, SavantModule::CLIENTS_HASHARRAY)

			client = SavantModule.hash_by_id(clientsArray, project["client"])

			currency = ""

			if params[:invoice]["currency"] == "EUR"
				currency = "€"
			elsif params[:invoice]["currency"] == "USD"
				currency = "$"
			elsif params[:invoice]["currency"] == "GBP"
				currency = "£"
			end
			
			# compile invoice strings
			invoice_str = template.download_to_string(:content_type => "text/html")
			invoice_str = invoice_str.gsub('#{invoice_id}', @new_id.to_s)
			invoice_str = invoice_str.gsub('#{invoice_send_date}', params[:invoice]["send_date"])
			invoice_str = invoice_str.gsub('#{invoice_description}', params[:invoice]["description"])
			invoice_str = invoice_str.gsub('#{amount}', currency + " " + params[:invoice]["amount"])
			invoice_str = invoice_str.gsub('#{job_id}', params[:invoice]["project"].to_s)
			
			client_address = client["name"] + "<br />" + client["address_1"] + "<br />" + client["address_2"] + "<br />" + client["zip_code"] + "<br />" + client["city"] + "<br />" + client["country"]
			invoice_str = invoice_str.gsub('#{client_address}', client_address)

			if client["country"] != "The Netherlands"
				invoice_str = invoice_str.gsub('#{diverted_vat}', "Vat is diverted to: " + client["vat_no"] )
				invoice_str = invoice_str.gsub('#{total_amount}', currency + " " + params[:invoice]["amount"] )										
				invoice_str = invoice_str.gsub('#{vat_amount}', "")		
			else
				vat =  params[:invoice]["amount"].to_f * 0.19
				total = params[:invoice]["amount"].to_i + vat

				invoice_str = invoice_str.gsub('#{diverted_vat}', "VAT 19%")	
				invoice_str = invoice_str.gsub('#{vat_amount}', currency + " " + vat.to_s)
				invoice_str = invoice_str.gsub('#{total_amount}', currency + " " +  total.to_s )										
			end


			# upload file
			file = drive.upload_from_string(invoice_str, invoice_title, :content_type => "text/html")
			invoiceCollection = savantCollection.subcollection_by_title(SavantModule::INVOICES)
			invoiceCollection.add(file)

			redirect_to(:action => 'overview', :id => 'invoices')
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
			
			redirect_to(:action => 'overview', :id => 'projects')
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

			redirect_to(:action => 'overview', :id => 'clients')
		end
	end

	def overview
		drive = session[:google_drive_session]

		if params[:id] == "invoices"
			@worksheet = SavantModule.get_sheet(drive, SavantModule::INVOICES_SHEET).worksheets[0]
		elsif params[:id] == "clients"
			@worksheet = SavantModule.get_sheet(drive, SavantModule::CLIENTS_SHEET).worksheets[0]
		elsif params[:id] == "projects"
			@worksheet = SavantModule.get_sheet(drive, SavantModule::PROJECTS_SHEET).worksheets[0]
		end
	end
end



