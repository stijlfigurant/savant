module SavantModule
	
	# root collection
	SAVANT = "Savant"

	# sub collections
    TEMPLATES = "Templates"
    INVOICES = "Invoices"
    SPREADSHEETS = "Spreadsheets"

    # spreadsheet titles
    INVOICES_SHEET = "Invoices Overview"
    PROJECTS_SHEET = "Projects Overview"
    CLIENTS_SHEET = "Clients Overview"

    def create_sheet(drive, title, collection)
		# check if spreadsheet exist
		sheet = collection.files("title" => title, "title-exact" => "true")[0]

		# check if exists
		if sheet.nil?
			# if not existing, create it
			sheet = drive.create_spreadsheet(title)
			collection.add(sheet)
		end

		return sheet
    end
end