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
    render :json => { response: remove_nil(responses) }
  end

  def evaluate current_progress
    # get the current step
    current_step = current_progress.step
    menu = Menu.where(step_id: current_step.id).first
    if current_step.step_type == "menu"
      if !is_valid_option? menu, params[:text]
        responses = [{ type: "Response", text: get_random_response(current_step, "invalid").text, phone_number: person.phone_number }]

        options_txt = options_text(menu)
        if !options_txt.nil?
          responses << { type: "Response", text: options_text(menu), phone_number: person.phone_number }
        end
        return responses

      else
        option = get_valid_option(menu,params[:text])
        first_step = Step.find_by_order_index(0)

        if !has_already_executed_option? option
          execute_action(option)
          post_action = get_action(option)
          next_step = option.step
          random = get_random_response(current_step, "valid")
          
          if !random.nil?
            response = { type: "Response", text: random.text, phone_number: person.phone_number }
          end

          if !next_step.nil?
            question = get_random(next_step.questions)
            Progress.create! step_id: next_step.id, player_id: person.id, contact_id: person.id
            return [response, { type: "Question", text: personalize(question.text), phone_number: person.phone_number }, post_action, get_menu(next_step) ]
          else                      
            Progress.create! step_id: first_step.id, player_id: person.id, contact_id: person.id
            return [response, post_action, get_menu(first_step)]
          end
        else
          text = get_random_response(option.step, "completed").text
          personalized = text.gsub(/{{selection}}/, get_executed_option(option))
          response = [{ type: "Response", text: personalized, phone_number: person.phone_number }, get_menu(first_step) ]
        end
      end
    end
  end

  def get_executed_option option
    if option.step.menus.first.action == "pick-team"
      return person.team.name
    end
  end

  def has_already_executed_option? option
    if !option.step.nil? && !option.step.menus.empty? && option.step.menus.first.action == "pick-team"
      return !person.team_id.nil?
    end
    return false
  end

  def get_action option
    if option.menu.action == "subscribe"
      response_type = (option.text.downcase.starts_with? "yes")? "valid" : "invalid"
      action = ResponseAction.where(step_id: option.menu.step_id, response_type: response_type).first
      if !action.nil?
        return { type: "Action", name: action.name, action_type: action.action_type, parameters: person.team.name }
      else
        return nil
      end
    end
  end

  def execute_action option    
    if option.menu.action == "pick-team"
      team = Team.find_by_name(option.text)
      person.team_id = team.id
      person.save!
    elsif option.menu.action == "subscribe"
      if option.text.downcase.starts_with? "yes"
        person.subscribed = true
      else
        person.subscribed = false
      end
      person.save!
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

  def options_text menu
    if !menu.nil?
      menu.options.collect { |opt| "#{opt.key}. #{opt.text}" }.join("\r\n")    
    end
  end

  def get_menu step
    menu = Menu.where(step_id: step.id).first
    if !menu.nil?
      return { type: "Response", text: options_text(menu), phone_number: person.phone_number }
    end
  end

  def get_random_response step, type
    if !type.nil?
      get_random(SystemResponse.where(step_id: step.id, response_type: type))
    else
      get_random(SystemResponse.where(step_id: step.id))
    end
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
