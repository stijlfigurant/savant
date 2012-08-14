module ApplicationHelper
	def error_messages_for(object) 
		render(:partial => 'partials/errors', :locals => {:object => object})
	end
end
