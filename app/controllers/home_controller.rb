class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token 
  before_action :set_contact, only: [:wizard, :wizard_new]

  def wizard_new
    puts "#{params}"
    if is_text?
      if is_reset?
        response = reset        
      else
        current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
        if @contact.bot_complete          
          rsp = get_localized_response(current_progress.step, "end")
          responses = []
          if !response.nil?
            responses << rsp.to_result(@contact)
          end
          # render :json => { response: responses }        
          response = responses
        else
          
          if current_progress.nil?
            # start the steps
            response = start
            # render :json => { response: response } 
          else
            response = remove_nil(progress_step(current_progress, params[:text]))
            send_responses response
            # render :json => { response: remove_nil(response) }
          end
        end
      end
    elsif is_receipt?
      message = Message.find_by(external_id: params[:id])
      if !message.nil?
        message.received = true
        message.save!
      end
      response = nil
    end
    render json: { response: response }
  end

  def wizard
    if params.has_key?(:text)
      if params[:text].downcase == ENV['RESET_CODE'].downcase
        number = @contact.phone_number
        Progress.where(contact_id: @contact.id).destroy_all
        Contact.delete_all
        render json: { response: [ { type: "Response", text: "Type #{ENV['RESTART_CODE']} to restart", phone_number: number }] }
      else
        current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
        if @contact.bot_complete          
          response = get_localized_response(current_progress.step, "end")
          responses = []
          if !response.nil?
            responses << response.to_result(@contact)
          end
          render :json => { response: responses }        
        else
          
          if current_progress.nil?
            # start the steps
            response = start
            render :json => { response: response } 
          else
            response = progress_step(current_progress, params[:text])
            render :json => { response: remove_nil(response) }
          end
        end
      end
    elsif !params.has_key?(:text) && !@contact.bot_complete      
      current_progress = Progress.where("contact_id =?", @contact.id).order(id: :asc).last
      if !current_progress.nil?
        responses = [ get_localized_response(current_progress.step, "multimedia").to_result(@contact) ]
        
        if !current_progress.step.next_step.nil?
          Progress.create! step_id: current_progress.step.next_step_id, contact_id: @contact.id  
          responses << get_localized_question(current_progress.step.next_step).to_result(@contact)
          add_actions(responses, current_progress.step, "valid")
        else
          # if there is nothing after this then finish
          random_response = get_localized_response(current_progress.step, "final")
          @contact.bot_complete = true
          @contact.save!
          if !random_response.nil?
            responses << random_response.to_result(@contact)
          end
          add_actions(responses, current_progress.step, "valid")
        end

        render :json => { response: remove_nil(responses) }
      else
        response = start
        render :json => { response: remove_nil(response) }     
      end
    else
      render :json => { response: [] }
    end
  end


  def self.is_valid_date? str
    if str.length > 8
      begin
        date = Date.parse(str)
        return HomeController.is_over_18?(date)
      rescue ArgumentError
        return false
      end
    else
      str = str.gsub("-","/")      
      str = str.gsub(".","/")      
      begin
        date = Date.strptime(str, '%d/%m/%y')
        return HomeController.is_over_18?(date)
      rescue ArgumentError
        return false        
      end
    end    
  end

  def self.is_over_18? dt
    (Date.today - dt).to_i / 365 >= 18
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
      Contact.delete_all
      text = "Send #{ENV['RESTART_CODE']} to restart"
      send_message text, phone_number
      [{ type: "Response", text: text, phone_number: phone_number }]
    end

    def start
      first_step = Step.find_by_order_index(0)      
      if !first_step.nil?
        question = get_localized_question(first_step)
        if !question.nil?
          Progress.create! step_id: first_step.id, contact_id: @contact.id

          send_message question.personalize(@contact), @contact.phone_number

          return [ question.to_result(@contact) ]
        end
      end
    end

    def send_responses responses
      responses.each do |response|
        if response[:type] != "ImageResponse"
          send_message response[:text], response[:phone_number]
        else
          binding.pry
          send_image response[:image], response[:phone_number]
          send_message response[:text], response[:phone_number]
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
      params[:text].downcase == ENV['RESET_CODE'].downcase
    end

    def is_text?
      params[:notification_type] == "MessageReceived"
    end

    def is_receipt?
      params[:notification_type] == "DeliveryReceipt"
    end

    def is_valid? step, value
      if step.step_type != "dob"
        # matches?(step.expected_answer, value)
        HomeController.matches_search?(step.expected_answer, value)
      elsif step.step_type == "dob"
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
      # binding.pry
      step = progress.step
      if step.step_type == "opt-in" || step.step_type == "dob"
        # if it is an opt-in i.e. yes or no
        contact = progress.contact

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
        else
          # send the final response
          random_response = get_localized_response(step, "final")  
          @contact.bot_complete = true
          @contact.save!
          if !random_response.nil?
            responses << random_response.to_result(@contact)
          end
          add_actions(responses, step, "final")
        end
        return responses
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
end
