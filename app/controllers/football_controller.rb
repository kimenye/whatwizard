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
      if !is_valid_option? current_step, menu, params[:text]
        responses = [{ type: "Response", text: get_random_response(current_step, "invalid").text, phone_number: person.phone_number }]

        options_txt = options_text(menu)
        if !options_txt.nil?
          responses << { type: "Response", text: options_text(menu), phone_number: person.phone_number }
        end
        return responses

      else
        option = get_valid_option(current_step,menu,params[:text])
        first_step = Step.find_by_order_index(0)

        if !option.nil?
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
            # binding.pry
            text = get_random_response(option.step, "completed").text
            personalized = text.gsub(/{{selection}}/, get_executed_option(option))
            response = [{ type: "Response", text: personalized, phone_number: person.phone_number }, get_menu(first_step) ]
          end
        else
          # we record the prediction
          record_predictions(current_step)
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

  def record_predictions step
    prediction = params[:text]
    match_key = prediction.split(" ")[0]
    if prediction.split(" ").size == 2
      home_score = prediction.split(" ")[1].split("-")[0].strip
      away_score = prediction.split(" ")[1].split("-")[1].strip
      # puts "I am 2"
    elsif prediction.split(" ").size == 4
      home_score = prediction.split(" ")[1].strip
      away_score = prediction.split(" ")[3].strip
      # puts "I am 4"
    else

    end

    # puts "Away Score => #{away_score} \n Home Score => #{home_score} \n Prediction => #{prediction}"
    round = Round.last
    n = 0
    question = get_random(step.questions)
    round.matches.each do |match|
      if match_key == @keys[n]
        prediction = Prediction.where(match_id: match.id, player_id: person.id, confirmed: nil).first
        if prediction.nil?
          Prediction.create! player_id: person.id, match_id: match.id, home_score: home_score, away_score: away_score
        else
          prediction.home_score = home_score
          prediction.away_score = away_score

          prediction.save!
        end
      end
      n = n + 1
    end

    player_predictions = ""

    @keys.each do |key|
      # puts "Matches hash => #{matches_hash(round)}"
      match = matches_hash(round)[key] unless matches_hash(round).nil?
      if !match.nil? 
        if match[:predicted]
          player_predictions = player_predictions + "#{key}. #{match[:home_team]} #{match[:predicted_home_score]} #{match[:away_team]} #{match[:predicted_away_score]} \r\n"
        else
          player_predictions = player_predictions + "#{key}. #{match[:home_team]} - #{match[:away_team]} \r\n"
        end
      end
    end
    # puts "Predictions => #{player_predictions}"
    predictions_response = { type: "Response", text: player_predictions, phone_number: person.phone_number }
    return [{ type: "Question", text: question.text, phone_number: person.phone_number}, predictions_response]
  end

  def matches_hash round
    n = 0
    matches = {}
    round.matches.each do |match|
      prediction = Prediction.where(match_id: match.id, player_id: person.id).first
      if !prediction.nil?
        matches[@keys[n]] = {
          :home_team => Team.find(match.home_team_id).name,
          :away_team => Team.find(match.away_team_id).name,
          :match => match,
          :predicted => !Prediction.where(match_id: match.id, player_id: person.id).first.nil?,
          :predicted_home_score => prediction.home_score,
          :predicted_away_score => prediction.away_score
        }
      else
        matches[@keys[n]] = {
          :home_team => Team.find(match.home_team_id).name,
          :away_team => Team.find(match.away_team_id).name,
          :match => match,
          :predicted => !Prediction.where(match_id: match.id, player_id: person.id).first.nil?
        }
      end
      n = n + 1
    end
    matches
  end

  def get_valid_option step, menu, text
    if !menu.nil?
      menu.options.each do |opt|
        if opt.key.downcase == text.downcase
          return opt
        end
      end
      return nil
    else
      return nil
    end
  end

  def is_valid_option? step, menu, text
    if !menu.nil?
      return !get_valid_option(step, menu,text).nil?
    else
      if step.name == "Play"
        return ('A'..'O').to_a.include? params[:text].split(" ")[0].strip
      end
    end
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
    if step.name == "Play"
      round = Round.last
      @keys = ('A'..'O').to_a[0, round.matches.count]
      # puts "Keys => #{@keys}"
      n = 0
      matches = ""
      question = get_random(step.questions)
      round.matches.each do |match|
        matches = matches + "#{@keys[n]}. #{Team.find(match.home_team_id).name} - #{Team.find(match.away_team_id).name} \r\n"
        n = n + 1
      end

      return { type: "Response", text: matches, phone_number: person.phone_number }

    else
      if !menu.nil?
        return { type: "Response", text: options_text(menu), phone_number: person.phone_number }
      end
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
