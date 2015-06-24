class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token 
  before_action :set_contact, only: [:wizard]
  after_action :record_response, only: [:wizard]

  # def wizard_new
  #   # puts "#{params}"
  #   if is_text?
  #     if is_reset?
  #       response = reset        
  #     else
  #       @current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
  #       if @contact.bot_complete          
  #         rsp = get_localized_response(@current_progress.step, "end")
  #         responses = []
  #         if !response.nil?
  #           responses << rsp.to_result(@contact)
  #         end
  #         # render :json => { response: responses }        
  #         response = responses
  #       else
          
  #         if @current_progress.nil?
  #           # start the steps
  #           response = start params[:text]
  #           # render :json => { response: response } 
  #         else
  #           if !is_last?
  #             response = remove_nil(progress_step(@current_progress, params[:text]))
  #             send_responses response
  #           else
  #             # the last step
  #             response = get_localized_response(@current_progress.step, "end")
  #             @contact.bot_complete = true
  #             @contact.save!
  #             if !response.nil?
  #               send_responses [response]
  #             end
  #           end
  #           # render :json => { response: remove_nil(response) }
  #         end
  #       end
  #     end
  #   elsif is_receipt?
  #     message = Message.find_by(external_id: params[:id])
  #     if !message.nil?
  #       message.received = true
  #       message.save!
  #     end
  #     response = nil
  #   elsif is_image?
  #     if !@contact.bot_complete
  #       current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
  #       if !current_progress.nil?
  #         responses = [ get_localized_response(current_progress.step, "multimedia").to_result(@contact) ]
          
  #         if !current_progress.step.next_step.nil?
  #           Progress.create! step_id: current_progress.step.next_step_id, contact_id: @contact.id  
  #           responses << get_localized_question(current_progress.step.next_step).to_result(@contact)
  #           add_actions(responses, current_progress.step, "valid")
  #         else
  #           # if there is nothing after this then finish
  #           random_response = get_localized_response(current_progress.step, "final")
  #           @contact.bot_complete = true
  #           @contact.save!
  #           if !random_response.nil?
  #             responses << random_response.to_result(@contact)
  #           end
  #           add_actions(responses, current_progress.step, "valid")
  #         end

  #         # render :json => { response: remove_nil(responses) }
  #         response = remove_nil(responses)
  #         send_responses response
  #       else
  #         response = start
  #         render :json => { response: remove_nil(response) }     
  #       end
  #     end
  #   end
  #   render json: { response: response }
  # end

  def wizard
    if is_text?
      
      # Check progress first in case an answer of one of the steps is a start of another wizard?
      @current = Progress.where(contact_id: @contact.id).order(id: :desc).first
      text = params[:text]

      wizards = Wizard.get_reset_wizards(text)
      if !wizards.empty?
        wizard = wizards.first
        number = @contact.phone_number
        Progress.where(contact_id: @contact.id).destroy_all
        @contact.delete
        render json: { response: [ { type: "Response", text: "Send #{wizard.start_keyword} to restart", phone_number: number }] }
      else
        if @contact.bot_complete 
          responses = []
          if !@current.nil?
            response = get_localized_response(@current.step, "end")
            if !response.nil?
              responses << response.to_result(@contact)
            end
          end
          render :json => { response: responses }        
        else
          if @current.nil?
            # check to see if there is any wizard matching that keyword
            # wizard = Wizard

            wizards = Wizard.get_starting_wizards(text)
            if !wizards.empty?
              
              # only ever deal with the first wizard
              wizard = wizards.first
              response = wizard.start(@contact)

              render json: response

            else
              render json: { ignore: true }
            end
          else
            response = progress_step(@current, params[:text])
            render :json => { response: remove_nil(response) }
          end
        end
      end
    end
  end

  # def wizard
  #   if params.has_key?(:text)
  #     if params[:text].downcase == ActsAsTenant.current_tenant.reset_code.downcase
  #       number = @contact.phone_number
  #       Progress.where(contact_id: @contact.id).destroy_all
  #       Contact.delete_all
  #       render json: { response: [ { type: "Response", text: "Send #{ActsAsTenant.current_tenant.start_code} to restart", phone_number: number }] }
  #     else
  #       # wizard = Wizard.find_by(start_keyword: params[:text])
  #       @current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
  #       if @contact.bot_complete 
  #         responses = []
  #         if !@current_progress.nil?
  #           response = get_localized_response(@current_progress.step, "end")
  #           if !response.nil?
  #             responses << response.to_result(@contact)
  #           end
  #         end
  #         render :json => { response: responses }        
  #       else
          
  #         if @current_progress.nil?
  #           # start the steps
  #           response = start params[:text]
  #           render :json => { response: response } 
  #         else
  #           response = progress_step(@current_progress, params[:text])
  #           render :json => { response: remove_nil(response) }
  #         end
  #       end
  #     end
  #   elsif !params.has_key?(:text) && !params[:notification_type] == "ReadReceipt" && !params[:notification_type] == "DeliveryReceipt" && !@contact.bot_complete      
  #     @current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
  #     if !@current_progress.nil?
  #       responses = [ get_localized_response(@current_progress.step, "multimedia").to_result(@contact) ]
        
  #       if !@current_progress.step.next_step.nil?
  #         Progress.create! step_id: @current_progress.step.next_step_id, contact_id: @contact.id  
  #         responses << get_localized_question(@current_progress.step.next_step).to_result(@contact)
  #         add_actions(responses, @current_progress.step, "valid")
  #       else
  #         # if there is nothing after this then finish
  #         random_response = get_localized_response(current_progress.step, "final")
  #         @contact.bot_complete = true
  #         @contact.save!
  #         if !random_response.nil?
  #           responses << random_response.to_result(@contact)
  #         end
  #         add_actions(responses, current_progress.step, "valid")
  #       end

  #       render :json => { response: remove_nil(responses) }
  #     else
  #       response = start
  #       render :json => { response: remove_nil(response) }     
  #     end
  #   else
  #     render :json => { response: [] }
  #   end
  # end


  def self.is_valid_date? str
    Step.is_valid_date? str
  end

  def self.matches_search? expected_answer, value
    matched = false
    expected_answer.split(",").each do |ans|
      if !(value.strip.downcase =~ Regexp.new(ans.strip.downcase)).nil?
        matched = true
      end
    end
    matched
  end

  private   

    def reset 
      phone_number = @contact.phone_number
      Progress.where(contact_id: @contact.id).destroy_all
      # Contact.delete_all
      
      text = "Send #{ActsAsTenant.current_tenant.start_code} to begin"
      send_message text, phone_number
      [{ type: "Response", text: text, phone_number: phone_number }]
    end

    def start start_keyword
      wizard = Wizard.where('start_keyword like ?', start_keyword).first
      if !wizard.nil?
        first_step = wizard.steps.first
        if !first_step.nil?
          question = get_localized_question(first_step)
          if !question.nil?
            Progress.create! step_id: first_step.id, contact_id: @contact.id
            message = question.personalize(@contact)
            if first_step.step_type == "menu"
              message += "\n#{question.options_text}"
            end
            send_message message, @contact.phone_number

            return [ question.to_result(@contact) ]
          end
        end
      else
        error = "No wizard with the start keyword '#{start_keyword}' exists. Please try again."
        send_message error, @contact.phone_number
        return { error: error }
      end
    end

    def send_responses responses
      responses.each do |response|
        if response[:type] != "ImageResponse"
          send_message response[:text], @contact.phone_number
        else
          send_image response[:image], @contact.phone_number
          if !response[:text].blank?
            send_message response[:text], @contact.phone_number
          end
        end
      end
    end

    def send_image image, phone_number
      logger.info("Sending #{image} to #{phone_number}")
      message = Message.create! phone_number: phone_number, message_type: "Image", image: image
      message.deliver
    end

    def send_message text, phone_number
      logger.info("Sending #{text} to #{phone_number}")
      message = Message.create! phone_number: phone_number, text: text, message_type: "Text"
      message.deliver
    end

    def is_reset?
      params[:text].downcase == ActsAsTenant.current_tenant.reset_code.downcase
    end

    def is_text?
      params[:notification_type] == "MessageReceived"
    end

    def is_receipt?
      params[:notification_type] == "DeliveryReceipt"
    end

    def is_image?
      params[:notification_type] == "ImageReceived"
    end

    def is_last?
      @current_progress && @current_progress.step.next_step.nil?
    end

    def is_valid? step, value
      if step.step_type != "dob"
        # matches?(step.expected_answer, value)
        HomeController.matches_search?(step.expected_answer, value)
      elsif step.step_type == "dob"
        logger.info "About to validate the date"
        return HomeController.is_valid_date?(value)
      end
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
      question = step.questions.first

      if step.step_type == "opt-in" || step.step_type == "dob"
        # if it is an opt-in i.e. yes or no
        contact = progress.contact

        logger.info("Step type #{step.step_type} #{contact.opted_in.nil?}")

        if contact.opted_in.nil?
          contact.opted_in = is_valid?(step, text)
          contact.save!
        end       

        if contact.opted_in
          # next_step = step.next_step
          if !step.next_step.nil?
            Progress.create! step_id: step.next_step_id, contact_id: @contact.id
          end
          responses = []
          
          valid = get_localized_response(step, "valid")
          if !valid.nil?
            responses << valid.to_result(contact)
          end

          if !step.next_step.nil?
            question = get_localized_question(Step.find(step.next_step))
            if !question.nil?
              responses << question.to_result(@contact)
            end
          else
            contact.bot_complete = true
            contact.save!
          end          

          add_actions(responses, step, "valid")
          return responses
        else
          responses = [ get_localized_response(step, "invalid").to_result(@contact) ]  
          add_actions(responses, step, "invalid")
          return responses
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
        responses = [ {type: "Response", text: personalize(random_response.text), phone_number: @contact.phone_number }]
        
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

        responses = [ get_localized_response(step, type).to_result(@contact) ]
        add_actions(responses,step,type)

        if valid && !fake
          if !step.next_step.nil?
            Progress.create! step_id: step.next_step_id, contact_id: @contact.id  
            responses << get_next_question(step.next_step, @contact)            
          end
        end
                
        return responses
      elsif step.step_type == "free-text"
        # random_response = get_random_response(step, "valid")
        random_response = get_localized_response(step, "valid")
        responses = [ random_response.to_result(@contact) ]
        if !step.next_step.nil?
          Progress.create! step_id: step.next_step_id, contact_id: @contact.id  
          responses << get_next_question(step.next_step, @contact)

          # send_message question.personalize(@contact), @contact.phone_number
          send_message responses.last[:text], @contact.phone_number
        else
          # send the final response
          random_response = get_localized_response(step, "final")  
          @contact.bot_complete = true
          @contact.save!
          if !random_response.nil?
            responses << random_response.to_result(@contact)
          end
          add_actions(responses, step, "final")
          send_message responses.last[:text], @contact.phone_number
        end
        return responses
      elsif step.step_type == "exact"
        if text.downcase == step.expected_answer
        else
          responses = [get_localized_response(step, "invalid").to_result(@contact)]
        end
        return responses
      elsif step.step_type == "menu"
        person = progress.contact
        if !Option.is_valid?(question, text)
          responses = [{ type: "Response", text: get_localized_response(step, "invalid").text, phone_number: person.phone_number }]

          return responses
        else
          next_step = step.next_step
          random = get_localized_response(step, "valid")
          
          if !random.nil?
            response = { type: "Response", text: random.text, phone_number: person.phone_number }
          end

          if !next_step.nil?
            question = get_random(next_step.questions)
            Progress.create! step_id: next_step.id, player_id: person.id, contact_id: person.id
            message = "#{question.text}\n#{question.options_text}"
            send_message message, @contact.phone_number
            return [response, { type: "Question", text: message, phone_number: person.phone_number } ]
          else
            send_message response[:text], @contact.phone_number
            @contact.update(bot_complete: true)
            return [response]
          end
        end
      else
        # yes-no
        responses = []
        if is_valid?(step, text)
          responses << get_localized_response(step, "valid").to_result(@contact)
          Progress.create! step_id: step.next_step_id, contact_id: @contact.id  
          if !step.next_step.nil?           
            responses << get_next_question(step.next_step, @contact)
          else
            rsp = finish(step)
            responses << rsp if !rsp.nil?
          end
          add_actions(responses, step,"valid")
        elsif is_invalid?(step, text)          
          responses << get_localized_response(step, "invalid").to_result(@contact)
          if step.allow_continue
            responses << move_on(step)
          end
          add_actions(responses, step,"invalid")
        elsif is_rebound?(step, text)        
          responses << get_localized_response(step, "rebound").to_result(@contact)
          add_actions(responses,step,"rebound")
        else
          # cant understand
          responses << get_localized_response(step, "unknown").to_result(@contact)          
          add_actions(responses, step,"unknown")
        end
        return responses
      end
    end

    def add_actions responses, step, response_type
      actions = ResponseAction.where(step_id: step.id, response_type: response_type)
      actions.each do |action|
        if action.delay.nil?
          responses << { type: "Action", name: action.name, action_type: action.action_type, parameters: action.parameters }
        else
          responses << { type: "Action", name: action.name, action_type: action.action_type, parameters: action.parameters, delay: action.delay }
        end
      end
      return responses
    end

    def finish step
      # random_response = get_random_response(step, "final")  
      random_response = get_localized_response(step, "final")
      @contact.bot_complete = true
      @contact.save!
      if !random_response.nil?
        return random_response.to_result(@contact)
      end
    end

    def move_on step
      Progress.create! step_id: step.next_step_id, contact_id: @contact.id  

      if !step.next_step.nil?           
        return get_localized_question(step.next_step).to_result(@contact)
      end
    end

    def get_next_question step, contact
      question = get_localized_question(step)
      if !question.nil?
        return question.to_result(@contact)
      end
    end

    def get_language
      @contact.language.nil?? ENV['DEFAULT_LANGUAGE'] : @contact.language
    end

    def get_localized_response step, type
      lang = get_language
      get_random(SystemResponse.where(step_id: step.id, response_type: type, language: lang))
    end

    def get_localized_question step
      lang = get_language
      get_random(step.questions.reject{ |q| q.language != lang })
    end

    def set_contact
      @contact = Contact.find_by_phone_number(params[:phone_number])
      if @contact.nil?
        @contact = Contact.create! phone_number: params[:phone_number], name: params[:name], opted_in: nil, bot_complete: false
      end
      @contact
    end

    def record_response
      if !@current_progress.nil? and is_text?
        Response.create! progress: @current_progress, text: params[:text], response_type: "Text"
      end
    end
end
