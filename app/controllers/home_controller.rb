class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token	
  before_action :set_contact, only: [:wizard]

  def wizard
  	# puts "#{params}"

    if params[:text].downcase != ENV['RESET_CODE'].downcase
      current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
      if current_progress.nil?

        # start the steps
        response = start
        render :json => { response: response } 
      else
        response = progress_step(current_progress, params[:text])
        render :json => { response: response }
      end
    else
      @contact.opted_in = nil
      @contact.save!
      Progress.where(contact_id: @contact.id).destroy_all
      render json: { response: [{ type: "Response", text: "Jedi! Start again you can...", phone_number: @contact.phone_number }, start.first] }
    end
  end

  private

  	def is_valid? step, value
  		matched = false
  		step.expected_answer.split(",").each do |ans|
  			if value.downcase == ans.strip.downcase
  				matched = true
  			end
  		end
  		matched
  	end

  	def progress_step progress, text
  		step = progress.step
  		if step.step_type == "opt-in"
  			# if it is an opt-in i.e. yes or no
  			contact = progress.contact

  			if contact.opted_in.nil?
  				contact.opted_in = is_valid?(step, text)
  				contact.save!
  			end  			

  			if contact.opted_in
  				# next_step = step.next_step
  				Progress.create! step_id: step.next_step_id, contact_id: @contact.id
  				
  				if !step.next_step.nil?
  					random_question = get_random(Step.find(step.next_step).questions)
			  		if !random_question.nil?
			  			raw_text = random_question.text
			  			raw_text = raw_text.gsub(/{{contact_name}}/, @contact.name) 			

						return [{ type: "Question", text: raw_text, phone_number: @contact.phone_number }]
			  		end
  				end
  			else
  				random_response = get_random(SystemResponse.where(step_id: step.id))
  				return [{ type: "Response", text: random_response.text, phone_number: @contact.phone_number, image_id: random_response.remote_asset_id  }]	 	
  			end
  		elsif step.step_type == "numeric"
  			# need to handle if we don't understand what the user has entered
  			value = text.to_i

  			if value == step.expected_answer.to_i
  				possible_responses = SystemResponse.where(step_id: step.id, response_type: "equals")
  			elsif value <= step.expected_answer.to_i
  				possible_responses = SystemResponse.where(step_id: step.id, response_type: "less_than")
  			else
  				possible_responses = SystemResponse.where(step_id: step.id, response_type: "more_than")
  			end
  			
        
  			random_response = get_random(possible_responses)
        responses = [ {type: "Response", text: random_response.text, phone_number: @contact.phone_number, image_id: random_response.remote_asset_id }]
        
        if !step.next_step.nil?
          Progress.create! step_id: step.next_step_id, contact_id: @contact.id  
          responses << get_next_question(step.next_step, @contact)
        end

  			return responses
  		elsif step.step_type == "serial"
  			value = text.to_s
  			r = Regexp.new(step.expected_answer)
  			type = (r =~ value) ? "valid" : "invalid"
  			
  			random_response = get_random_response(step, type)
  			return [{ type: "Response", text: random_response.text, phone_number: @contact.phone_number, image_id: random_response.remote_asset_id  }]
  		elsif step.step_type == "free-text"

        random_response = get_random_response(step, nil)
        responses = [{ type: "Response", text: random_response.text, phone_number: @contact.phone_number,image_id: random_response.remote_asset_id  }]
        if !step.next_step.nil?
          responses << get_next_question(step.next_step, @contact)
        end
        return responses
      else
  			# yes-no
  			responses = []
        
  			if is_valid?(step, text)
          random = get_random_response(step, "valid")
  				responses << { type: "Response", text: random.text, phone_number: @contact.phone_number,image_id: random.remote_asset_id  }
  				Progress.create! step_id: step.next_step_id, contact_id: @contact.id	
  				if !step.next_step.nil?  					
  					responses << get_next_question(step.next_step, @contact)
  				end
  			else
          random = get_random_response(step, "invalid")
  				responses << { type: "Response", text: random.text, phone_number: @contact.phone_number, image_id: random.remote_asset_id  }
  			end
  			return responses
  		end
  	end

  	def get_random_response step, type
      if !type.nil?
  		  get_random(SystemResponse.where(step_id: step.id, response_type: type))
      else
        get_random(SystemResponse.where(step_id: step.id))
      end
  	end

  	def get_next_question step, contact
  		random_question = get_random(Step.find(step).questions)
  		if !random_question.nil?
  			raw_text = random_question.text
  			raw_text = raw_text.gsub(/{{contact_name}}/, contact.name) 			

			  return { type: "Question", text: raw_text, phone_number: contact.phone_number }
  		end
  	end


  	def start
  		first_step = Step.find_by_order_index(0)  		
  		if !first_step.nil?
	  		random_question = get_random(first_step.questions)
	  		if !random_question.nil?
	  			raw_text = random_question.text
	  			raw_text = raw_text.gsub(/{{contact_name}}/, @contact.name)
				
				# send_msg raw_text  			

				Progress.create! step_id: first_step.id, contact_id: @contact.id
				return [{ type: "Question", text: raw_text, phone_number: @contact.phone_number }]
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
  			@contact = Contact.create! phone_number: params[:phone_number], name: params[:name], opted_in: nil
  		end
  		@contact
  	end
end
