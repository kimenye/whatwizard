class VotingController < ApplicationController
  skip_before_action :verify_authenticity_token 
  before_action :set_contact, only: [:wizard]

  def wizard
    if is_text? && !@contact.bot_complete
      text = params[:text]
      wizard = Wizard.where('start_keyword like ?', text.upcase).first
      progress = Progress.where(contact: @contact).last
      if wizard.nil? && progress.nil?
        render json: { ignore: true }
      else
        responses = progress(wizard, text)
        send_responses responses
        render json: { success: true, responses: responses }
      end
    else
      render json: { success: true }
    end
  end

  def progress wizard, response
    current = Progress.where(contact_id: @contact.id).order(id: :desc).first
    responses = []    
    if current.nil?
      # we are at the beginning
      # therefore return the welcome_text of the wizard

      # get the first step of the wizard
      step = wizard.steps.order(:order_index).first
      Progress.create! step: step, contact: @contact, response: response
      responses = [ wizard.welcome_text, step.to_question ]
    else
      valid = evaluate response, current.step

      if !valid        
        # check if the answer is other
        if !current.step.is_other? response
          # now check if our previous response was an other
          # marking this a valid other response

          was_other = current.step.is_other? current.response
          if !was_other
            responses = [ current.step.wrong_answer ]
          else
            # move to the next step
            responses = move_forward(current, response)
          end
        else
          # update
          current.response = response
          current.save!

          responses = [ current.step.rebound ]
        end
      else
        # check if the current step is the last
        current_step = current.step
        if !current_step.is_last?
          # if we have a next step
          responses = move_forward(current, response)
        else
          # return the final message
          responses = [ current.step.final_message ]
          @contact.bot_complete = true
          @contact.save!
        end
      end
    end
    responses
  end

  def move_forward current_progress, response
    next_step = current_progress.step.next_step
    Progress.create! step: next_step, contact: @contact, response: response

    responses = [ next_step.to_question ]
  end 

  def evaluate response, step
    step.is_valid? response
  end

  def send_responses responses
    responses.each do |response|
      send_message response, @contact.phone_number
    end
  end

  def send_message text, phone_number
    logger.info("Sending #{text} to #{phone_number}")
    message = Message.create! phone_number: phone_number, text: text, message_type: "Text"
    message.deliver
  end

end