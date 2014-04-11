class FootballController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_player, only: [:wizard]
  
  def wizard
    responses = []
    if params.has_key?(:text)
      current_progress = Progress.where("player_id =?", @player.id).order(id: :asc).last
      if current_progress.nil?
        responses = start(@player)
      end
    end
    render :json => { response: responses }
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

  def get_menu step
    menu = Menu.where(step_id: step.id).first
    options_text = menu.options.collect { |opt| "#{opt.key}. #{opt.text}" }.join("\r\n")
    { type: "Response", text: options_text, phone_number: person.phone_number }
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
