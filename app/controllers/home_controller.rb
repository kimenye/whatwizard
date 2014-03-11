class HomeController < ApplicationController
  

  before_action :set_contact, only: [:wizard]

  def wizard
  	# puts "#{params}"

  	current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
  	if current_progress.nil?

  		# start the steps
  		start
  	else
  		progress_step(current_progress, params[:text])
  	end
  end

  private

  	def progress_step progress, text
  		step = progress.step
  		if step.step_type == "opt-in"
  			# if it is an opt-in i.e. yes or no
  			contact = progress.contact
  			contact.opted_in = text.downcase == "yes"
  			contact.save!

  			if contact.opted_in
  				# next_step = step.next_step
  				Progress.create! step_id: step.next_step_id, contact_id: @contact.id
  			end
  		end
  	end


  	def start
  		first_step = Step.find_by_order_index(0)  		
  		if !first_step.nil?
	  		random_question = get_random(first_step.questions)
	  		if !random_question.nil?
	  			raw_text = random_question.text
	  			raw_text = raw_text.gsub(/{{contact_name}}/, @contact.name)
				
				send_msg raw_text  			

				Progress.create! step_id: first_step.id, contact_id: @contact.id
	  		end
	  	end
  	end

  	def send_msg text
  		if Rails.env == "production"
  		end
  	end

  	def get_random records
  		records[rand(records.length)]
  	end

  	def set_contact
  		@contact = Contact.find_by_phone_number(params[:phone_number])
  		if @contact.nil?
  			@contact = Contact.create! phone_number: params[:phone_number], name: params[:name], opted_in: false
  		end
  		@contact
  	end
end
