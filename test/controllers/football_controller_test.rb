require "test_helper"

class FootballControllerTest < ActionController::TestCase

	before do
		Player.delete_all
		Team.delete_all
		Match.delete_all
		Round.delete_all
		Prediction.delete_all
		Result.delete_all
		Step.delete_all
	  	Question.delete_all
	  	Progress.delete_all
	  	Menu.delete_all
	  	Option.delete_all

	  	@phone_number = "254722778348"	
	  	@arsenal_team = Team.create! name: "Arsenal"
	  	@everton_team = Team.create! name: "Everton"

	  	@round_one = Round.create! name: "Round One"
	  	@match = Match.create! home_team_id: @arsenal_team.id, away_team_id: @everton_team.id, round_id: @round_one.id

	  	@prediction_menu_response = { type: "Response", text: "A. #{@arsenal_team.name} - #{@everton_team.name}", phone_number: @phone_number }


		@home = Step.create! name: "Welcome", step_type: "menu", order_index: 0
	  	@team_step = Step.create! name: "My Team", step_type: "menu", order_index: 1
	  	@notifications_step = Step.create! name: "Notifications", step_type: "menu", order_index: 2
	  	@play_step = Step.create! name: "Play", step_type: "menu", order_index: 3


	  	@prompt = Question.create! text: "Welcome to the Ongair Football on WhatsApp. Please chose an option below by replying with a letter. e.g. To find out about this service reply with the letter 'A'", step_id: @home.id
	  	@home_menu = Menu.create! name: "Home", step_id: @home.id	  	
	  		

	  	@opt_about = Option.create! index: 0, key: "A", text: "About Ongair Football", menu_id: @home_menu.id
		@opt_my_team = Option.create! index: 1, key: "B", text: "My Team", menu_id: @home_menu.id, step_id: @team_step.id
		@opt_play = Option.create! index: 2, key: "C", text: "Play", menu_id: @home_menu.id, step_id: @play_step.id

		@home_menu_response = { type: "Response", text: "#{@opt_about.key}. #{@opt_about.text}\r\n#{@opt_my_team.key}. #{@opt_my_team.text}\r\n#{@opt_play.key}. #{@opt_play.text}", phone_number: @phone_number }

		team_menu = Menu.create! name: "Teams", step_id: @team_step.id, action: "pick-team"
		@team_question = Question.create! text: "Please select a team", step_id: @team_step.id	
		@manu = Option.create! index: 0, key: "A", text: "Manchester United", menu_id: team_menu.id, step_id: @notifications_step.id
		@arsenal = Option.create! index: 1, key: "B", text: "Arsenal", menu_id: team_menu.id, step_id: @notifications_step.id

		
		@play_question = Question.create! text: "Make your predictions", step_id: @play_step.id


		@valid_team = SystemResponse.create! text: "Well, we'll see how they fair. All the best", response_type: "valid", step_id: @team_step.id
		@selected_response = SystemResponse.create! text: "You already selected {{selection}}", response_type: "completed", step_id: @team_step.id
		
		@notifications_question = Question.create! text: "Would you like to receive FREE notifications such as updates about your team?", step_id: @notifications_step.id

		notifications_menu = Menu.create! name: "Notifications", step_id: @notifications_step.id, action: "subscribe"
		@yes = Option.create! index: 0, key: "A", text: "Yes I'd like to receive", menu_id: notifications_menu.id
		@no = Option.create! index: 0, key: "B", text: "No thanks", menu_id: notifications_menu.id

		@add_to_list_action = ResponseAction.create! name: "Add to Team List", action_type: "add-to-list", response_type: "valid", step_id: @notifications_step.id

		@yes_subcription = SystemResponse.create! text: "Cool", response_type: "valid", step_id: @notifications_step.id
	end

	test "should create a player if it doesn't already exist" do	  	
	    post :wizard, {text: ENV['START_KEYWORD'], name: "Player", phone_number: "254722778348"}
	    assert_response :success
	    player = Player.find_by_phone_number("254722778348") 
	    assert_equal false, player.nil?    
	end

	test "It should return the welcome message when a user sends the start keyword the first time" do				
		post :wizard, {text: ENV['START_KEYWORD'], name: "Player", phone_number: @phone_number }
		assert_response :success

		expected = { response: [{ type: "Question", text: @prompt.text, phone_number: @phone_number }, @home_menu_response ]}
    	assert_equal expected.to_json, response.body
	end

	test "It should repeat the menu if the user responds with a wrong menu option" do
		player = Player.create! name: "Text", phone_number: @phone_number, subscribed: nil
		Progress.create! player_id: player.id, step_id: @home.id
		rsp = SystemResponse.create! step_id: @home.id, response_type: "invalid", text: "I didn't understand that. Please reply with one of the following options" 

		post :wizard, {text: "Aaaa", name: "Text", phone_number: @phone_number }
		expected = { response: [{ type: "Response", text: rsp.text, phone_number: @phone_number }, @home_menu_response ]}
		assert_equal expected.to_json, response.body
	end

	test "it should progress a user to the next step if the user responds with the right menu option" do
		player = Player.create! name: "Text", phone_number: @phone_number, subscribed: nil
		Progress.create! player_id: player.id, step_id: @home.id

		post :wizard, {text: "B", name: "Text", phone_number: @phone_number }
		assert_response :success

		expected = { response: [{ type: "Question", text: @team_question.text, phone_number: @phone_number }, { type: "Response", text: "#{@manu.key}. #{@manu.text}\r\n#{@arsenal.key}. #{@arsenal.text}", phone_number: @phone_number }]}
    	assert_equal expected.to_json, response.body
	end

	test "It should allow a player to select their favorite team" do
		player = Player.create! name: "Text", phone_number: @phone_number, subscribed: nil
		Progress.create! player_id: player.id, step_id: @team_step.id

		post :wizard, {text: "B", name: "Text", phone_number: @phone_number }
		assert_response :success

		player = Player.first
		assert_equal player.team_id, @arsenal_team.id
	end

	test "If a menu option has no next step, it should return to the home" do
		player = Player.create! name: "Text", phone_number: @phone_number, subscribed: nil
		Progress.create! player_id: player.id, step_id: @team_step.id

		@arsenal.step_id = nil
		@arsenal.save!

		post :wizard, {text: "B", name: "Text", phone_number: @phone_number }
		assert_response :success

		expected = { response: [{ type: "Response", text: @valid_team.text, phone_number: @phone_number }, @home_menu_response ]}
		assert_equal expected.to_json, response.body

		player = Player.first
		assert_equal player.team_id, @arsenal_team.id

		last_progress = Progress.where("player_id = ?", player.id).order(id: :asc).last
		assert_equal last_progress.step_id, @home.id
	end

	test "It should add a player to their teams distribution list only if they consent to be added" do
		player = Player.create! name: "Text", phone_number: @phone_number, subscribed: nil
		Progress.create! player_id: player.id, step_id: @team_step.id

		post :wizard, {text: "B", name: "Text", phone_number: @phone_number }
		assert_response :success

		expected = { response: [{ type: "Response", text: @valid_team.text, phone_number: @phone_number }, { type: "Question", text: @notifications_question.text, phone_number: @phone_number }, { type: "Response", text: "#{@yes.key}. #{@yes.text}\r\n#{@no.key}. #{@no.text}", phone_number: @phone_number }]}
		assert_equal expected.to_json, response.body
		
		player = Player.first
		assert_equal player.team_id, @arsenal_team.id

		post :wizard, {text: "A", name: "Text", phone_number: @phone_number }
		assert_response :success

		last_progress = Progress.where("player_id = ?", player.id).order(id: :asc).last
		assert_equal last_progress.step_id, @home.id

		player = Player.first
		assert_equal player.subscribed, true

		expected = { response: [{ type: "Response", text: @yes_subcription.text, phone_number: @phone_number }, { type: "Action", name: @add_to_list_action.name, action_type: @add_to_list_action.action_type, parameters: @arsenal_team.name }, @home_menu_response]}
		assert_equal expected.to_json, response.body
	end

	test "If a player has already answered a question the should show that option" do
		player = Player.create! name: "Text", phone_number: @phone_number, team_id: @arsenal_team.id
		Progress.create! player_id: player.id, step_id: @home.id
		Progress.create! player_id: player.id, step_id: @team_step.id
		Progress.create! player_id: player.id, step_id: @notifications_step.id		
		Progress.create! player_id: player.id, step_id: @home.id

		post :wizard, { text: "B", name: "Text", phone_number: @phone_number }
		assert_response :success

		expected = { response: [{ type: "Response", text: "You already selected Arsenal", phone_number: @phone_number}, @home_menu_response]}
		assert_equal expected.to_json, response.body
	end

	test "A player can only submit predictions if they is a round to be played" do
		player = Player.create! name: "Text", phone_number: @phone_number, team_id: @arsenal_team.id
		Progress.create! player_id: player.id, step_id: @home.id

		post :wizard, { text: "C", name: "Text", phone_number: @phone_number }
		assert_response :success		

		expected = { response: [{ type: "Question", text: @play_question.text, phone_number: @phone_number}, @prediction_menu_response] }
		assert_equal expected.to_json, response.body
	end
end
