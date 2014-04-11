require "test_helper"

class FootballControllerTest < ActionController::TestCase

before do
	Player.delete_all
	Team.delete_all
	Match.delete_all
	Round.delete_all
	Prediction.delete_all
	Result.delete_all
end

test "should create a player if it doesn't already exist" do
  	
    post :wizard, {name: "dsfsdf", phone_number: "254722778348"}
    assert_response :success
    player = Player.find_by_phone_number("254722778348") 
    assert_equal false, player.nil?    
end

end
