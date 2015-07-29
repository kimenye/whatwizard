class VotingController < ApplicationController
  skip_before_action :verify_authenticity_token 
  before_action :set_contact, only: [:wizard]

  def wizard
    if is_text?
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
      Progress.create! step: step, contact: @contact
      responses = [ wizard.welcome_text, step.to_question ]
    else
      valid = evaluate response, current.step
      # binding.pry
      if !valid
        responses = [ current.step.wrong_answer ]
      end
    end
    responses
  end

  def evaluate response, step
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