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


		@home = Step.create! name: "Welcome", step_type: "menu", order_index: 0
	  	@prompt = Question.create! text: "Welcome to the Ongair Football on WhatsApp. Please chose an option below by replying with a letter. e.g. To find out about this service reply with the letter 'A'", step_id: @home.id
	  	@home_menu = Menu.create! name: "Home", step_id: @home.id	  	
	  	@phone_number = "254722778348"

	  	@opt_a = Option.create! index: 0, key: "A", text: "About Ongair Football", menu_id: @home_menu.id
		@opt_b = Option.create! index: 1, key: "B", text: "My Team", menu_id: @home_menu.id
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

		expected = { response: [{ type: "Question", text: @prompt.text, phone_number: @phone_number }, { type: "Response", text: "#{@opt_a.key}. #{@opt_a.text}\r\n#{@opt_b.key}. #{@opt_b.text}", phone_number: @phone_number }]}
    	assert_equal expected.to_json, response.body
	end

	test "It should repeat the menu if the user responds with a wrong menu option" do
		player = Player.create! name: "Text", phone_number: @phone_number, subscribed: nil
		Progress.create! player_id: player.id, step_id: @home.id

		post :wizard, {text: "What is this?", name: "Text", phone_number: @phone_number }
		expected = { response: [{ type: "Response", text: "I didn't understand that. Please reply with one of the following options", phone_number: @phone_number }, { type: "Response", text: "#{@opt_a.key}. #{@opt_a.text}\r\n#{@opt_b.key}. #{@opt_b.text}", phone_number: @phone_number }]}
		assert_equal expected.to_json, response.body
	end

end
