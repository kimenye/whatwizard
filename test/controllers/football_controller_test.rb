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
	end

	test "should create a player if it doesn't already exist" do	  	
	    post :wizard, {text: ENV['START_KEYWORD'], name: "Player", phone_number: "254722778348"}
	    assert_response :success
	    player = Player.find_by_phone_number("254722778348") 
	    assert_equal false, player.nil?    
	end

	test "It should return the welcome message when a user sends the start keyword the first time" do
		welcome = Step.create! name: "Welcome", step_type: "menu", order_index: 0
		# SystemResponse.create! text: "Cool!", step_id: opt_step.id, response_type: "valid"
		prompt = Question.create! text: "Welcome to the Ongair Football on WhatsApp", step_id: welcome.id
	end

end
