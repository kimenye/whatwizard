class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token 
  before_action :set_contact, only: [:wizard]

  def wizard
    if params.has_key?(:text) 
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
        render json: { response: [ start.first ] }
      end
    else      
      current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
      if !current_progress.nil?
        random_response = get_random_response(current_progress.step, "multimedia")
        responses = [{ type: "Response", text: personalize(random_response.text), phone_number: @contact.phone_number, image_id: (!random_response.media.nil? ? random_response.media.remote_asset_id : nil)  }]
        
        if !current_progress.step.next_step.nil?
          Progress.create! step_id: current_progress.step.next_step_id, contact_id: @contact.id  
          responses << get_next_question(current_progress.step.next_step, @contact)
        end

        render :json => { response: responses }
      else
        response = start
        render :json => { response: response }     
      end
    end
  end

  private

    def is_valid? step, value
      matches?(step.expected_answer, value)
    end

    def matches? match, value
      matched = false
      if !match.nil?
        match.split(",").each do |ans|
          if value.downcase == ans.strip.downcase
            matched = true
          end
        end
      end
      matched
    end

    def is_rebound? step, value
      matches?(step.rebound, value)
    end

    def is_invalid? step, value
      matches?(step.wrong_answer, value)
    end

    def is_fake? step, value
      matches?(step.wrong_answer, value)
    end

    def cant_understand? step, value
      !is_invalid?(step,value) && !is_valid?(step, value) 
    end

    def personalize raw_text
      raw_text.gsub(/{{contact_name}}/, @contact.name)
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
              return [{ type: "Question", text: personalize(random_question.text), phone_number: @contact.phone_number, image_id: (!random_question.media.nil? ? random_question.media.remote_asset_id : nil) }]
            end
          end
        else
          random_response = get_random(SystemResponse.where(step_id: step.id))
          return [{ type: "Response", text: personalize(random_response.text), phone_number: @contact.phone_number, image_id: (!random_response.media.nil? ? random_response.media.remote_asset_id : nil)  }]    
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
        responses = [ {type: "Response", text: personalize(random_response.text), phone_number: @contact.phone_number, image_id: (!random_response.media.nil? ? random_response.media.remote_asset_id : nil)  }]
        
        if !step.next_step.nil?
          Progress.create! step_id: step.next_step_id, contact_id: @contact.id  
          responses << get_next_question(step.next_step, @contact)
        end

        return responses
      elsif step.step_type == "serial"
        value = text.to_s
        r = Regexp.new(step.expected_answer)
        type = (r =~ value) ? "valid" : "invalid"
        valid = type == "valid"
        fake = is_fake?(step, text)
        type = "fake" if fake

        random_response = get_random_response(step, type)  
        responses = [{ type: "Response", text: personalize(random_response.text), phone_number: @contact.phone_number, image_id: (!random_response.media.nil? ? random_response.media.remote_asset_id : nil)  }]
        
        if valid && !fake
          if !step.next_step.nil?
            Progress.create! step_id: step.next_step_id, contact_id: @contact.id  
            responses << get_next_question(step.next_step, @contact)
          end
        end
                
        return responses
      elsif step.step_type == "free-text"

        random_response = get_random_response(step, "valid")
        responses = [{ type: "Response", text: personalize(random_response.text), phone_number: @contact.phone_number,image_id: (!random_response.media.nil? ? random_response.media.remote_asset_id : nil)   }]
        if !step.next_step.nil?
          responses << get_next_question(step.next_step, @contact)
        else
          # send the final response
          random_response = get_random_response(step, "final")  
          if !random_response.nil?
            responses << { type: "Response", text: personalize(random_response.text), phone_number: @contact.phone_number, image_id: (!random_response.media.nil? ? random_response.media.remote_asset_id : nil)  }
          end
        end
        return responses
      else
        # yes-no
        responses = []
        if is_valid?(step, text)
          random = get_random_response(step, "valid")
          responses << { type: "Response", text: personalize(random.text), phone_number: @contact.phone_number,image_id: (!random.media.nil? ? random.media.remote_asset_id : nil)   }
          Progress.create! step_id: step.next_step_id, contact_id: @contact.id  
          if !step.next_step.nil?           
            responses << get_next_question(step.next_step, @contact)
          end
        elsif is_invalid?(step, text)
          random = get_random_response(step, "invalid")
          responses << { type: "Response", text: personalize(random.text), phone_number: @contact.phone_number, image_id: (!random.media.nil? ? random.media.remote_asset_id : nil)   }
          if step.allow_continue
            responses << move_on(step)
          end
        elsif is_rebound?(step, text)          
          random = get_random_response(step, "rebound")
          responses << { type: "Response", text: personalize(random.text), phone_number: @contact.phone_number, image_id: (!random.media.nil? ? random.media.remote_asset_id : nil)   }              
        else
          # cant understand
          random = get_random_response(step, "unknown")
          responses << { type: "Response", text: personalize(random.text), phone_number: @contact.phone_number, image_id: (!random.media.nil? ? random.media.remote_asset_id : nil)   }
        end
        return responses
      end
    end

    def move_on step
      Progress.create! step_id: step.next_step_id, contact_id: @contact.id  

      if !step.next_step.nil?           
        return get_next_question(step.next_step, @contact)
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
        return { type: "Question", text: personalize(random_question.text), phone_number: contact.phone_number, image_id: (!random_question.media.nil? ? random_question.media.remote_asset_id : nil) }
      end
    end


    def start
      first_step = Step.find_by_order_index(0)      
      if !first_step.nil?
        random_question = get_random(first_step.questions)
        if !random_question.nil?
          Progress.create! step_id: first_step.id, contact_id: @contact.id
          return [{ type: "Question", text: personalize(random_question.text), phone_number: @contact.phone_number }]
        end
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
