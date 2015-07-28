require "test_helper"

class VotingControllerTest < ActionController::TestCase
  before do
    @phone_number = accounts(:eatout).phone_number
  end

  test "Should only begin if we have the correct start word" do
    post :wizard, { name: 'Trevor', phone_number: '254722123456', text: 'Hi', notification_type: 'MessageReceived', account: @phone_number }
    assert_response :success

    expected = { ignore: true }
    assert_equal expected.to_json, response.body

    contact = Contact.find_by(phone_number: '254722123456', name: 'Trevor')
    assert_not contact.nil?
  end

  test "Should begin if we have the correct start word" do
    wizard = wizards(:taste)
    start = wizard.start_keyword.downcase

    post :wizard, { name: 'Trevor', phone_number: '254722123456', text: start, notification_type: 'MessageReceived', account: @phone_number }
    assert_response :success

    step_one = steps(:italian) 

    expected = { success: true, responses: [ wizard.welcome_text, step_one.to_question ] }
    assert_equal expected.to_json, response.body
  end
end