class FootballController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_player, only: [:wizard]
  
  def wizard
    responses = []
    if params.has_key?(:text)
      current_progress = Progress.where("player_id =?", @player.id).order(id: :asc).last
      if current_progress.nil?
        responses = start(@player)
      else
        responses = evaluate(current_progress)
      end
    end
    render :json => { response: responses }
  end

  def evaluate current_progress
    # get the current step
    current_step = current_progress.step
    menu = Menu.where(step_id: current_step.id).first
    if current_step.step_type == "menu"
      if !is_valid_option? menu, params[:text]
        return [{ type: "Response", text: get_random_response(current_step, "invalid").text, phone_number: person.phone_number }, { type: "Response", text: options_text(menu), phone_number: person.phone_number } ]
      else
        option = get_valid_option(menu,params[:text])
        current_step = option.step
        question = get_random(current_step.questions)
        Progress.create! step_id: current_step.id, player_id: person.id, contact_id: person.id
        return [{ type: "Question", text: personalize(question.text), phone_number: person.phone_number }, get_menu(current_step) ]
      end
    end
  end

  def get_valid_option menu, text
    menu.options.each do |opt|
      if opt.key.downcase == text.downcase
        return opt
      end
    end
    return nil
  end

  def is_valid_option? menu, text
    return !get_valid_option(menu,text).nil?
  end

  def start person
    first_step = Step.find_by_order_index(0)      
    if !first_step.nil?
      random_question = get_random(first_step.questions)
      if !random_question.nil?
        Progress.create! step_id: first_step.id, player_id: person.id, contact_id: person.id
        return [{ type: "Question", text: personalize(random_question.text), phone_number: person.phone_number }, get_menu(first_step) ]
      end
    end
  end

  # def progress_step progress, text
  #   step = progress.step
  #   puts "Hey"
  #   if step.step_type == "menu"
  #     if step.name == "My Team"
  #       random_question = get_random(step.questions)
  #       if !random_question.nil?
  #         Progress.create! step_id: step.id, player_id: person.id, contact_id: person.id
  #         return [{ type: "Question", text: personalize(random_question.text), phone_number: person.phone_number }, get_menu(step) ]
  #       end
  #     end      
  #   end
  # end

  def options_text menu
    menu.options.collect { |opt| "#{opt.key}. #{opt.text}" }.join("\r\n")    
  end

  def get_menu step
    menu = Menu.where(step_id: step.id).first
    { type: "Response", text: options_text(menu), phone_number: person.phone_number }
  end

  def person
    @player
  end

  def set_player
    @player = Player.find_by_phone_number(params[:phone_number])
    if @player.nil?
      @player = Player.create! phone_number: params[:phone_number], name: params[:name], subscribed: nil
    end
    @player
  end
end
