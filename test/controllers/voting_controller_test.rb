require "test_helper"

class VotingControllerTest < ActionController::TestCase
  before do
    @phone_number = accounts(:eatout).phone_number
    Progress.delete_all
    Contact.delete_all
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

    # progress should be marked to be this step
    contact = Contact.find_by(phone_number: '254722123456', name: 'Trevor')
    assert_not contact.nil?

    progress = Progress.find_by(contact: contact, step: step_one)
    assert_not progress.nil?
    assert_equal start, progress.response

    # user responds with non-existent option
    post :wizard, user_entry('blahblah')
    assert_response :success

    expected = { success: true, responses: [ step_one.wrong_answer ]}
    assert_equal expected.to_json, response.body

    # user responds with the first correct option
    post :wizard, user_entry('1')
    assert_response :success

    continental = steps(:continental)
    progress = Progress.where(contact: contact).last

    assert_equal continental, progress.step
    expected = { success: true, responses: [ continental.to_question ]}
    assert_equal expected.to_json, response.body    
  end

  test "Should be able to enter free-text as an option" do
    wizard = wizards(:taste)
    step = wizard.first_step

    contact = Contact.create! phone_number: '254722123456', name: 'Trevor', account: accounts(:eatout)
    progress = Progress.create! step: step, contact: contact, response: 'taste'

    other = options(:ital_other)

    post :wizard, user_entry(other.key)
    assert_response :success

    expected = { success: true, responses: [ step.rebound ] }
    assert_equal expected.to_json, response.body

    # now the user enters a free-text option
    post :wizard, user_entry('Nairobi Java House')
    assert_response :success

    expected = { success: true, responses: [ step.next_step.to_question ]}
    assert_equal expected.to_json, response.body
  end

  private

    def user_entry text
      { name: 'Trevor', phone_number: '254722123456', text: text, notification_type: 'MessageReceived', account: @phone_number }
    end
end