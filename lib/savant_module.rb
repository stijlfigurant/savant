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
    SETTINGS_SHEET = "Settings"

	INVOICES_HASHARRAY = [
    	{"key" => "id", 		"string" => "ID" },
    	{"key" => "project",	"string" => "Project" },	
    	{"key" => "currency",	"string" => "Currency" },
    	{"key" => "amount",		"string" => "Amount" },
    	{"key" => "description","string" => "Description" },
    	{"key" => "send_date",	"string" => "Send Date" },
    	{"key" => "pay_date",	"string" => "Pay Date" }
    ]


    PROJECTS_HASHARRAY = [
		{"key" => "id", 		"string" => "ID" },
    	{"key" => "name",		"string" => "Name" },	
    	{"key" => "client",		"string" => "Client" },
    	{"key" => "status",		"string" => "Status" }
    ]

    CLIENTS_HASHARRAY = [
    	{"key" => "id", 		"string" => "ID" },
    	{"key" => "name",		"string" => "Name" },	
    	{"key" => "address_1",	"string" => "Address 1" },
    	{"key" => "address_2",	"string" => "Address 2" },
    	{"key" => "zip_code",	"string" => "Zip Code" },
    	{"key" => "city",		"string" => "City" },
    	{"key" => "country",	"string" => "Country" },
    	{"key" => "vat_no",		"string" => "VAT Number" }
    ]

     SETTINGS_HASHARRAY = [
        {"key" => "name",       "string" => "Name" },   
        {"key" => "address",    "string" => "Address" },
        {"key" => "zip_code",   "string" => "Zipcode" },
        {"key" => "city",       "string" => "City" },
        {"key" => "phone",      "string" => "Phone" },
        {"key" => "url",        "string" => "Url" },
        {"key" => "roc",        "string" => "Room of Commerce" },
        {"key" => "vat_no",     "string" => "VAT Number" },
        {"key" => "bank_account","string" => "Bank Account" },
        {"key" => "iban",       "string" => "IBAN" },
        {"key" => "swift",       "string" => "Swift" }
    ]

    # TODO: predefine rows


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

    def get_sheet(drive, title)
    	savantCollection = self.get_collection(drive)
    	collection = savantCollection.subcollection_by_title(SavantModule::SPREADSHEETS)
    	sheet = collection.files("title" => title, "title-exact" => "true")[0]
    	return sheet
    end

    def get_collection(drive)
	 	rootCollection = drive.root_collection			
		savantCollection = rootCollection.subcollection_by_title(SavantModule::SAVANT)

    	return savantCollection
    end

    def get_new_id(worksheet)
    	# get the latest id
		if worksheet.num_rows > 1
			last_id = worksheet[worksheet.num_rows, 1]
		else
			last_id = 0
		end

		# increment
		new_id = last_id.to_i + 1

    	return new_id
    end

    def worksheet_to_array(worksheet, hashArray)
    	# make new array
    	array = Array.new

    	# loop through worksheet rows
		for row in 2..worksheet.num_rows

			# for ever row, create a new hash
			newHash = Hash.new
			
			# loop through row columns
			for col in 1..worksheet.num_cols

				# get hash key for column
				hashkey = hashArray[col-1]["key"]

				# insert value under hashkey
				newHash[hashkey] = worksheet[row,col]
			end

			# add new hash to array
			array.push(newHash)
		end

		# return array
		return array
    end

    def insert_values(worksheet, values, hashArray)

		row = worksheet.num_rows + 1
			
    	for i in 0..hashArray.size - 1
    		
    		hashkey = hashArray[i]["key"]

			#Rails.logger.debug i+1
    		Rails.logger.debug hashkey
    		Rails.logger.debug values[hashkey]

    		worksheet[row, i+1] = values[hashkey]
    	end

    	worksheet.save()
    end

    def hash_by_id(array, id)
        for hash in array
            Rails.logger.debug hash["id"]
            Rails.logger.debug id
            
            if hash["id"].to_s == id.to_s
                #logger.debug id
                Rails.logger.debug hash
                return hash
            end
        end
    end
end