require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should create a contact if it doesn't already exist" do
    post :wizard, {name: "dsfsdf", phone_number: "254722778348", text: "yes"}
    # Contact.find_by_phone_number 
    assert_response :success
  end

end
