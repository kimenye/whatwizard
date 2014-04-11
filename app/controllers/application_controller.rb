class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def get_random records
    records[rand(records.length)]
  end

  def personalize raw_text
    raw_text.gsub(/{{contact_name}}/, person.name)
  end

	def get_random_response step, type
	  if !type.nil?
	    get_random(SystemResponse.where(step_id: step.id, response_type: type))
	  else
	    get_random(SystemResponse.where(step_id: step.id))
	  end
	end
end
